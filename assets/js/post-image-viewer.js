(function () {
  "use strict";

  var MIN_SCALE = 0.05;
  var MAX_SCALE = 8;
  var ZOOM_STEP = 1.25;
  var IMAGE_URL_PATTERN = /\.(?:avif|bmp|gif|jpe?g|png|svg|webp)(?:[?#].*)?$/i;

  function ready(callback) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", callback, { once: true });
    } else {
      callback();
    }
  }

  function absoluteUrl(value) {
    try {
      return new URL(value, document.baseURI).href;
    } catch (error) {
      return value;
    }
  }

  function largestSrcsetCandidate(image) {
    if (!image.srcset) {
      return "";
    }

    var candidates = image.srcset.split(",").map(function (candidate) {
      var parts = candidate.trim().split(/\s+/);
      var descriptor = parts[1] || "1x";
      var widthMatch = descriptor.match(/^([\d.]+)w$/);
      var densityMatch = descriptor.match(/^([\d.]+)x$/);

      return {
        url: parts[0],
        width: widthMatch ? Number(widthMatch[1]) : 0,
        density: densityMatch ? Number(densityMatch[1]) : 0
      };
    }).filter(function (candidate) {
      return candidate.url;
    });

    if (!candidates.length) {
      return "";
    }

    var hasWidths = candidates.some(function (candidate) {
      return candidate.width > 0;
    });

    candidates.sort(function (left, right) {
      return hasWidths
        ? left.width - right.width
        : left.density - right.density;
    });

    return absoluteUrl(candidates[candidates.length - 1].url);
  }

  function sourceFor(image, linkedImage) {
    return absoluteUrl(
      image.getAttribute("data-full-src") ||
      (linkedImage ? linkedImage.href : "") ||
      largestSrcsetCandidate(image) ||
      image.currentSrc ||
      image.src
    );
  }

  function captionFor(image) {
    var figure = image.closest("figure");
    var figureCaption = figure ? figure.querySelector("figcaption") : null;
    var paragraph = image.closest("p");
    var strongCaption = paragraph ? paragraph.querySelector("strong") : null;
    var paragraphCaption = paragraph ? paragraph.textContent.trim() : "";

    return (
      (figureCaption && figureCaption.textContent.trim()) ||
      (strongCaption && strongCaption.textContent.trim()) ||
      image.alt.trim() ||
      paragraphCaption
    );
  }

  ready(function () {
    var dialog = document.querySelector("[data-post-image-viewer]");

    if (!dialog || typeof dialog.showModal !== "function") {
      return;
    }

    var viewport = dialog.querySelector("[data-viewer-viewport]");
    var stage = dialog.querySelector("[data-viewer-stage]");
    var viewerImage = dialog.querySelector("[data-viewer-image]");
    var caption = dialog.querySelector("[data-viewer-caption]");
    var scaleOutput = dialog.querySelector("[data-viewer-scale]");
    var zoomOutButton = dialog.querySelector("[data-viewer-zoom-out]");
    var zoomInButton = dialog.querySelector("[data-viewer-zoom-in]");
    var fitButton = dialog.querySelector("[data-viewer-fit]");
    var actualButton = dialog.querySelector("[data-viewer-actual]");
    var originalLink = dialog.querySelector("[data-viewer-original]");
    var closeButton = dialog.querySelector("[data-viewer-close]");
    var openLabel = dialog.getAttribute("data-open-label") || "Open image full screen";
    var loadingLabel = dialog.getAttribute("data-loading-label") || "Loading…";
    var errorLabel = dialog.getAttribute("data-error-label") || "Unable to load image";
    var imageLabel = dialog.getAttribute("data-image-label") || "Image";
    var lastTrigger = null;
    var currentScale = 1;
    var fitScale = 1;
    var viewMode = "fit";

    function clampScale(value) {
      var minimum = Math.min(MIN_SCALE, fitScale || MIN_SCALE);
      return Math.min(MAX_SCALE, Math.max(minimum, value));
    }

    function updateControls() {
      var percentage = Math.round(currentScale * 100);

      scaleOutput.textContent = percentage + "%";
      fitButton.setAttribute("aria-pressed", viewMode === "fit" ? "true" : "false");
      actualButton.setAttribute("aria-pressed", viewMode === "actual" ? "true" : "false");
      zoomOutButton.disabled = currentScale <= Math.min(MIN_SCALE, fitScale) + 0.001;
      zoomInButton.disabled = currentScale >= MAX_SCALE - 0.001;
      dialog.classList.toggle("is-fit", viewMode === "fit");
      dialog.classList.toggle("is-actual-size", viewMode === "actual");
    }

    function centreViewport(previousCentre) {
      window.requestAnimationFrame(function () {
        var centre = previousCentre || { x: 0.5, y: 0.5 };
        viewport.scrollLeft = Math.max(0, centre.x * stage.scrollWidth - viewport.clientWidth / 2);
        viewport.scrollTop = Math.max(0, centre.y * stage.scrollHeight - viewport.clientHeight / 2);
      });
    }

    function setScale(value, mode, preserveCentre) {
      if (!viewerImage.naturalWidth || !viewerImage.naturalHeight) {
        return;
      }

      var previousCentre = preserveCentre ? {
        x: (viewport.scrollLeft + viewport.clientWidth / 2) / Math.max(stage.scrollWidth, 1),
        y: (viewport.scrollTop + viewport.clientHeight / 2) / Math.max(stage.scrollHeight, 1)
      } : null;

      currentScale = clampScale(value);
      viewMode = mode;
      viewerImage.style.width = Math.round(viewerImage.naturalWidth * currentScale) + "px";
      viewerImage.style.height = Math.round(viewerImage.naturalHeight * currentScale) + "px";
      updateControls();
      centreViewport(previousCentre);
    }

    function fitImage() {
      if (!viewerImage.naturalWidth || !viewerImage.naturalHeight) {
        return;
      }

      var horizontalSpace = Math.max(1, viewport.clientWidth - 48);
      var verticalSpace = Math.max(1, viewport.clientHeight - 48);
      fitScale = Math.min(
        1,
        horizontalSpace / viewerImage.naturalWidth,
        verticalSpace / viewerImage.naturalHeight
      );
      setScale(fitScale, "fit", false);
    }

    function actualSize() {
      setScale(1, "actual", false);
    }

    function zoomBy(factor) {
      setScale(currentScale * factor, "zoom", true);
    }

    function closeViewer() {
      if (dialog.open) {
        dialog.close();
      }
    }

    function openViewer(image, trigger, linkedImage) {
      var source = sourceFor(image, linkedImage);
      var imageCaption = captionFor(image);

      lastTrigger = trigger;
      caption.textContent = imageCaption;
      caption.hidden = !imageCaption;
      viewerImage.alt = image.alt || imageCaption;
      originalLink.href = source;
      scaleOutput.textContent = loadingLabel;
      dialog.classList.add("is-loading");
      document.body.classList.add("post-image-viewer-open");

      if (!dialog.open) {
        dialog.showModal();
      }

      closeButton.focus({ preventScroll: true });
      viewerImage.src = source;
    }

    viewerImage.addEventListener("load", function () {
      dialog.classList.remove("is-loading", "has-error");
      window.requestAnimationFrame(fitImage);
    });

    viewerImage.addEventListener("error", function () {
      dialog.classList.remove("is-loading");
      dialog.classList.add("has-error");
      scaleOutput.textContent = errorLabel;
    });

    document.querySelectorAll(".post-content img:not([data-no-lightbox])").forEach(function (image, index) {
      if (image.closest("[data-post-image-viewer], button")) {
        return;
      }

      var link = image.closest("a");
      var linkedImage = link && IMAGE_URL_PATTERN.test(link.href) ? link : null;

      if (link && !linkedImage) {
        return;
      }

      var trigger = linkedImage || image;
      var imageCaption = captionFor(image);
      var conciseCaption = imageCaption.length <= 120 ? imageCaption : "";
      var triggerDescription = image.alt.trim() || image.title.trim() || conciseCaption || imageLabel + " " + (index + 1);
      var accessibleLabel = triggerDescription ? openLabel + ": " + triggerDescription : openLabel;

      trigger.classList.add("post-image-viewer-trigger");
      trigger.setAttribute("aria-haspopup", "dialog");
      trigger.setAttribute("aria-controls", dialog.id);
      trigger.setAttribute("aria-label", accessibleLabel);

      if (!linkedImage) {
        trigger.setAttribute("role", "button");
        trigger.setAttribute("tabindex", "0");
      }

      trigger.addEventListener("click", function (event) {
        event.preventDefault();
        openViewer(image, trigger, linkedImage);
      });

      trigger.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          openViewer(image, trigger, linkedImage);
        }
      });
    });

    zoomOutButton.addEventListener("click", function () {
      zoomBy(1 / ZOOM_STEP);
    });

    zoomInButton.addEventListener("click", function () {
      zoomBy(ZOOM_STEP);
    });

    fitButton.addEventListener("click", fitImage);
    actualButton.addEventListener("click", actualSize);
    closeButton.addEventListener("click", closeViewer);

    viewerImage.addEventListener("dblclick", function () {
      if (viewMode === "fit") {
        actualSize();
      } else {
        fitImage();
      }
    });

    stage.addEventListener("click", function (event) {
      if (event.target === stage) {
        closeViewer();
      }
    });

    dialog.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        event.preventDefault();
        closeViewer();
        return;
      }

      if (event.altKey || event.ctrlKey || event.metaKey) {
        return;
      }

      if (event.key === "+" || event.key === "=") {
        event.preventDefault();
        zoomBy(ZOOM_STEP);
      } else if (event.key === "-") {
        event.preventDefault();
        zoomBy(1 / ZOOM_STEP);
      } else if (event.key === "0") {
        event.preventDefault();
        fitImage();
      } else if (event.key === "1") {
        event.preventDefault();
        actualSize();
      }
    });

    dialog.addEventListener("close", function () {
      document.body.classList.remove("post-image-viewer-open");
      viewerImage.removeAttribute("src");
      viewerImage.removeAttribute("style");
      dialog.classList.remove("is-loading", "has-error", "is-fit", "is-actual-size");
      caption.textContent = "";
      originalLink.removeAttribute("href");

      if (lastTrigger && lastTrigger.isConnected) {
        lastTrigger.focus({ preventScroll: true });
      }
    });

    window.addEventListener("resize", function () {
      if (dialog.open && viewMode === "fit") {
        fitImage();
      }
    });
  });
}());
