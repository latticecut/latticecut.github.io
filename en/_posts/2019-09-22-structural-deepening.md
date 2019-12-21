---
layout: post
title: "Structural Deepening"
lang: en
lang-ref: structural-deepening
date: 2019-09-22
---

***

## Preamble

I have been intending to write a blog for some time.

This is to help me better understand my own ideas about the papers I read, talks I hear, and increasingly important, the social media threads I view.

As such, most of the material on this blog is just a reworking of other peoples ideas, perhaps in a different context, or with comparisons drawn with the work of others. I hope it is all referenced correctly. To this end, I am interested in feedback and input on clarifications, corrections, errata, emendations and so forth.

This blog is focused on my interest in the different mechanisms of invention, innovation and the evolution of technology. Most of my recent discussions in these matter have been with Dr Dave Chapman at the UCL School of Management where I teach courses on designing predictive systems (ML) and technology strategy.

In particular, I'm interested in a examining aspects of Simon Wardley's mapping framework[^wardley2016] in greater detail. For those of you that don't know the background to this, you can begin reading [On being lost](https://medium.com/wardleymaps/on-being-lost-2ef5f05eb1ec) to learn more about it. Reading Chapters 2 and 3 will only take you an hour or so.

To me, the appeal of this mapping framework is that it views a business (model) as a directed graph evolving in a space (topological, ordinal, metric). I think this has lots of advantages over other things we commonly refer to as business models - but more on that at a later date - lets start by having a look at a map.

***

# The structure of invention

These series of posts are about the evolution of technologies, and the transitions between competing technologies in the context of a business.

This first post draws heavily on the work of W. Brian Arthur[^arthur2007].

The x-axis of a Wardley Map (Figure 1 below) displays the maturity of a technology over its life cycle. The maturity is divided into four stages; Genesis, Custom Build, Product, Utility[^stages].

[^stages]: Following [Wardley 2016](https://medium.com/wardleymaps/finding-a-new-purpose-8c60c9484d3b), Figure 76, it is in principle possible to measure the stage of maturity of a component by assessing the language used to describe the technology in the various corpora that refer to it. From academic publications, to patents in the Genesis stage, to technical standards documentation in the early Product stage and finally to marketing collateral, sales manuals and so forth at different stages of commercial development. Not all components need pass through every stage of development and I will ignore the details of measuring the x-position from corpora. It is assumed as given for now, including the number of stages, and I will write more on this in future posts.

To start with, illustrated in Figure 1, we can see that a component moves from left to right as it matures. I will use the word *technology* and *component* interchangeably in this blog as a means to fulfill a purpose[^techdef].

[^techdef]: Following Arthur (2007 p. 276)[^arthur2007]  The word technology has two other legitimate meanings: a body of practices, activities and components, and “the totality of the means employed by a people to provide itself with the objects of material culture" (Arthur, 2007, p. 276)[^arthur2007].

Initially, on the lefthand side in the *Genesis stage* the component has to be created for the first time. At this stage we don't have a full design but a concept – or in the words of Arthur a *principle* – that demonstrates how we can create something new that achieves a desired purpose. Here a *principle* refers to the idea of being able to use a phenomena for some purpose.(ibid. p. 2007)

![Figure 1](/assets/0001_Structural_Deepening_Fig01.png)
**Figure 1. Map showing the evolution of a component through 4 stages, from Genesis to Commodity.**

At the Genesis stage, a new component might have been *kludged* together from existing components or assemblies of existing components - a minimum viable prototype [MVP](https://) if you will. For example, according to Arthur (2009 p. 131)[^arthur2009], the first [cyclotron](https://en.wikipedia.org/wiki/Cyclotron) was assembled from parts that included a kitchen chair, a clothes tree, window glass, sealing wax and brass fittings!

The new technology, having proven its worth (at least in the mind of the originator(s))[^originators], or at least that the harnessed principle is viable, then begins its journey along a path of further development.

[^originators]: Following Arthur (2007 p. 279)[^arthur2007] I will call them *originators*, to avoid the lone eccentric connotation of “inventors”. The history of science has many examples of the co-discovery or rediscovery of similar ways to harness a phenomena for a particular purpose - something we will return to in a later blog post.

This is shown by arrow going left to right in the Wardley Map. During this process the component matures (or evolves) from an initial working technology towards a state that is more reliable, more efficient and more robust. We develop a detailed understanding of its viable operating conditions and this enables us to better understand the cost of delivery.

The development (or evolution) of the component is ultimately driven by supply and demand competition in the market (or similar mechanism) at different stages of maturity. Along this journey the component technology is often altered and augmented in a variety of different ways.

Let us, for now, ignore the details of the demand and supply pressures of different markets. We can simply think of a component as existing in several different states over the duration of its evolution. This is illustrated in Figure 2, where we have shown a component in three states during its life-cycle.

![Figure 2](/assets/0001_Structural_Deepening_Fig02.png)
**Figure 2. Evolution of a component from past to present to future through different realisations of the technology C[1] to C[3]. At each stage of development the technology must be made reliable, improved, scaled up and adapted to purposes. As we move from states 1-3, engineers can test better techniques, solve encountered problems, and create performance improvements based on different operating conditions.**

The initial working technology is in state C[1], at a previous time in the Genesis stage. C[2] is the current stage of the component in a Product stage and finally C[3] is an anticipated future state in the Commodity stage [^stages].  

## Purposed systems

Before discussing the behaviour of sets of components in more detail, lets us first look at the y-axis of the Wardley Map, labelled *value chain* [^yaxis].

[^yaxis]: There is ongoing discussion about the structure, and indeed necessity of, the y-axis in a Wardley Map (eg.[Ditch it.](https://twitter.com/swardley/status/1146769661297643521)). Whilst there is still a lot to be figured out (and this post skips over many nuances) I think of a map as a projection (mapping) from a high-dimensional space to a lower one. Most commonly we encounter this as going from a 3D real world to 2D cartographers map. Thinking of the 2D Wardley map as a projection into a lower dimensional space is useful - and we are likely to agree in due course on a definition and measurement process for a y-axis (or potentially multiple axes) that has broad utility - I am not in favour of getting rid of it!

At the highest level of abstraction the y-axis of the map can be thought of as linking purposes, to principles, to phenomena.

We can arrange these purposed systems in chains of dependancies starting with (user) needs. These needs might be personally or socially perceived - but they are the reason we created the component in the first place - and they sit at the top of the y-axis supported by a set of components and sub-components. It is the nature of technology that, at the end of this chain (or terminating branch) there is always a physical effect or a phenomenon that can be exploited to satisfy it.

Consider the example of a jet engine, illustrated in Figure 3. At the highest level of abstraction the engine is designed to generate thrust, a physical effect, to create flight to satisfy a user need.  

If go down a level of detail we can think about the different components that make up the engine. The engine consists of an air intake system, a compressor system (to compress the inducted air for combustion), a combustion system (to provide high-energy gas flow for the turbine), a turbine system (to drive the compressor and provide reactive thrust), and an exhaust section.(Otis, 1997)[^otis1997]



![Figure 3](/assets/0001_Structural_Deepening_Fig02.png)
**Figure 3. A simple jet engine**

Following Arthur (Arthur 2007 [^arthur2007]) we can maintain that each system of components, or *assembly* of components, itself has a purpose - that task that it is designed to carry out. If not, it would not exist. Consequently, technologies are put together or *combined* from component parts or assemblies in a recursive manner[^recursive].

[^recursive]: W. Brian Arthur talks about the recursive structure of technologies, such that technologies consist of parts - assemblies or sub-assemblies - that are themselves technologies.

Chains, or networks, or graphs of components are required to satisfy any suitably involved set of needs and therefore other sub-principles (and therefore sub-components) are required for a technology's practical working. Therefore, as we descend on the y-axis we proceed from purposes, through needs and their satisficing assembly of components, to effects and phenomena. This can been seen in Figure 4.

![Figure 4](/assets/0001_Structural_Deepening_Fig03.png)
**Figure 4. Purposed systems. Each component system has a purpose that can be thought of as a chain joining purposes to a principle to phenomena. Supporting activities and practices are included on the key for completeness but not shown.**

To return to the example of the jet engine, the assembly of components (the engine, or gas turbine) exploits the phenomenon that a mass expelled backward produces an equal and opposite forward reaction.

![Figure 5](/assets/0001_Structural_Deepening_Fig02.png)
**Figure 5. Generating thrust.**

However, the phenomenon exploited at a given level of abstraction of a map need not only be physical and "any reliable or repeatable effect from nature, or logic, or behaviour, or organisation may be harnessed for use" (ibid. pp. 276).

In practise, we will frequently draw a map at a level of abstraction that does not contain purposes and phenomena (and their implied causal dependancies), but focuses on a small set of components.


## Systems of components

As with any real world map, a Wardley Map is depicted at a level of abstraction (and consequent level of detail) to be useful for a particular task. Components are put together or *combined* from other component parts to create assemblies[^recursive] of technologies. For our purposes, a map will mean looking at sets of components of specific technologies - and in any particular map some components will be included and some omitted.



If we go down a level, each of these components is in turn supported, supplied, monitored and controlled by other sub-components: "the compressor system requires a variable vane actuating system (to set the vane angles appropriately to airflow velocity), and an anti-stall bleed system to control pressure surges (the tendency of the compressed air to blow backwards); the turbine system requires a blade cooling system, and a complicated set of shrouds and seals to prevent high-pressure gas leakage" (Arthur (2007 p. 277)[^arthur2007]). This is illustrated in Figure 3.

![Figure 3](/assets/0001_Structural_Deepening_Fig02.png)
**Figure 3. A slightly less simple jet engine. Jet Engine with additional sub-components**


## Focal technologies and the main assembly

Let us now turn to the question of what components to include on the map. The user *need* can be represented as a *customer* node at the top of the map. This is supported by a technology designed around the exploitation of some effect, as envisaged through some principle of use.

The method for achieving the purpose, through some *main principle* of use, will be referred to as the *main assembly*. This is illustrated in Figure 6.

![Figure 6](/assets/0001_Structural_Deepening_Fig04.png)
**Figure 6. Structure of the main assembly. The customer need is supported by a constellation of components and supporting activities - demarcated with a dotted line - that link it to a underlying set phenomena and effects.**

In practice, the *main assembly* refers to a core set of components (or methods and activities) that successfully achieve the purpose and allows us to focus a map at the level of a specific task.  Following Adner and Kapoor (Adner and Kapoor 2016[^adnerKapoor2016]) we identify this smallest functional component of the main assembly as the *focal technology*. The main assembly consists of the focal technology and other assemblies that support its working, regulate its function, and feed it with energy. These supporting assemblies require their own sub-components and sub-assemblies: controlling mechanisms, monitoring devices, input and output interfaces and so forth.

Considering the focal technology and the main assembly will allow us to draw a key distinction between the *as-developed* performance of a focal technology, and the *as-used performance* of the technology which depends additionally on the components which must co-develop to integrate as part of the main assembly.

In general in a Wardley map, we are interested in looking at the evolution of components over time to enable us to think strategically about how they can continue to provide support for a given purpose - or how they may be substituted as better alternative assemblies originate.

![Figure 7](/assets/0001_Structural_Deepening_Fig04.png)
**Figure 7. Structure of the main assembly of a jet engine.**

## An example of a jet engine

In this post we will not pay attention to the detail of the distribution (along the x-axis) of components that make up the main assembly - rather we will focus on the evolution of the main assembly itself from left to right in a manner similar to a single component illustrated in Figure 2.

E[0]-E[1]-E[2]

In Figure 7, we illustrate the evolution of the main assembly. We can see that it goes through a series of states A[1] to A[7] across the different stages of maturity. In the earliest version of the technology, A[1], we have a working version that links purpose with phenomena. However once development of the technology has got underway, different versions emerge. Some may come from the key technologies originators (e.g. A[2]), but initial progress attracts other groups of engineers into the filed, some possibly from labs or new startups that begin to tinker with the main assembly, for example A[3]. With further maturation the technology begins to exhibit variations in deployed solutions and the assembly is subject to usual selection pressures of supply and demand. "The many versions of a technology improve in small steps by the selection of better solutions to their internal design problems... Technologies become more complex - often much more complex - as they mature." Arthur (2009 p.132)[^arthur2009].

This process of increasing complexity is illustrated on the map with a node (with a dotted edge) that expands as the components in the main assembly increase in number and complexity. For example, think back to the jet engine with he addition of variable vane actuating system and an anti-stall bleed system as the engine main assembly increases in complexity.

![Figure 7](/assets/0001_Structural_Deepening_Fig07.png)
**Figure 7. Evolution of the main assembly.**

## Structure deepening

One mechanism for this increasing complexity is *structural deepening* where the performance limitations of the original *main principle* are overcome with the addition of other sub-principles (and therefore sub-components) to improve the envelop of the technology's practical performance. One example of the physical limitations that the principle of lithography imposes is that as "developers press integrated circuits to become denser, therefore accommodating more [gates and logic]... at some point the process that produces them... becomes limited by the wavelength of light." (ibid p.133)[^arthur2009] Adding sub-systems to work around such limitations drives technologies to elaborate as they evolve - and as sub-systems or assemblies themselves are technologies, and they too develop so they enhance overall performance.

Alternatively, reverting back to the example of the jet engine, as the engines are pushed to perform at higher temperatures the turbine blades soften as temperatures rise, so a component is added to create new airflow to cool the blades or a component that circulates a cooling material inside the blades themselves.  

In complex interconnected, interdependent, economies an ongoing source of improvement is that many sub-components are shared across different main assemblies, and therefore a great deal of development happens as components evolve in other adjacent assemblies.


In some technology examples, the components of the main assembly are integral to the device itself. This is the for example in the case of the jet engine. In other cases, the components are external to a device but form part of the operating context or wider environment. Take the case of the alternatives to the use of the internal combustion engine for the car. Fuel cells, or similar, will not pose a real substitute until they are augmented by sufficiently rich set of complementary components that constitute a developed hydrogen infrastructure.

# Direction of travel




# References

[^adnerKapoor2016]: Adner, R. and Kapoor, R., Innovation ecosystems and the pace of substitution: Re-examining technology S-curves, Strategic Management Journal, 37: 625-648, 2016

[^arthur2007]: Arthur, W. Brian, The Structure of Invention, Research Policy, 36, pages 274-287, 2007

[^arthur2009]: Arthur, W. Brian, The Nature of Technology, Penguin Books UK, 2009

[^otis1997]: Otis, 1997

[^wardley2016]: Wardley, S., Topographical intelligence in business, 2016

---
