---
layout: post
title: "Structural Deepening"
date: 2019-09-22
---

***

## Preamble

I have been intending to write a blog for some time.

This is to help me better understand my own ideas about the papers I read, talks I hear, and increasingly importantly the social media threads I view.

As such, most of the material on this blog is just a reworking of other peoples ideas, perhaps in a different context, or with comparisons drawn with the work of others. I hope it is all referenced correctly. To this end, I am interested in feedback and input on clarifications, corrections, errata, emendations and so forth.

I currently work in different fields, from machine learning, to law, and in different contexts from graduate education to tech startups. This blog is focused on my interest in the different mechanisms of invention, innovation and the evolution of technology. Most of my recent discussions in these matter have been with Dr Dave Chapman at the UCL School of Management.    

In particular, I'm interested in a examining Simon Wardley's mapping framework[^wardley2016] in greater detail. Most of these early posts are going to be about interpreting many of the other works in the (predominantly management science) literature in the context of a map.

For those of you that don't know the background to this, you can begin reading [On being lost](https://medium.com/wardleymaps/on-being-lost-2ef5f05eb1ec) to learn more about it.

The appeal of this mapping framework is that it views a business model as a directed graph in a metric (or ordinal) space - this appeals to me for several reasons - but more on that at a later date.

***

# The structure of invention

These series of posts are on the detail of the evolution of technologies and the transitions between different technologies in the context of a business. In future posts, this will touch on subjects such as *technical debt* or *obsolescence* but to start with I want to introduce some terminology. This first post draws heavily on the work of W. Brian Arthur with references cited below.

The x-axis of a Wardley Map (Figure 1 below) measures the maturity of a technology over its life cycle. The maturity is divided into four stages; Genesis, Custom Build, Product, Utility[^stages].

[^stages]: Following [Wardley 2016](https://medium.com/wardleymaps/finding-a-new-purpose-8c60c9484d3b), Figure 76, it is in principle possible to measure the stage of maturity of a component by assessing the language used to describe the technology in the various corpora that refer to it. From academic publications, to patents in the Genesis stage, to technical standards documentation in the early Product stage and finally to marketing collateral, sales manuals and so forth at different stages of commercial development. This is assumed as given for now, and I will write more on this in future posts.

To start with, illustrated in Figure 1, we can see that a component moves from left to right as it matures. I will use the word *technology* and *component* interchangeably in this blog quite simply as a means to fulfill a purpose[^techdef].


[^techdef]: Following Arthur (2007 p. 276)[^arthur2007]  The word technology has two other legitimate meanings: a body of practices and components, and “the totality of the means employed by a people to provide itself with the objects of material culture (Arthur, 2007, p. 276)[^arthur2007].


Initially, on the lefthand side in the *Genesis stage* the component has to be created for the first time. What is being sought at this stage is not a full design, not a full architecture, along with all the components and sub-components and a detailed understanding of its operating conditions. What is being sought is a base concept – a *principle* – a demonstration that we can create something new that takes us closer to achieving a desired purpose. A principle is the idea of use of a phenomenon for some purpose.

![Figure 1](/assets/0001_Structural_Deepening_Fig1.png)
**Figure 1. Map showing the evolution of a component through 4 stages, from Genesis to Commodity**


At this stage, it usually means the component has been *kludged* together from existing components or assemblies of existing components - an MVP if you will. For example, according to Arthur (2009 p. 131)[^arthur2009], Lawrence's first [cyclotron](https://en.wikipedia.org/wiki/Cyclotron) was assembled from parts that included a kitchen chair, a clothes tree, window glass, sealing wax and brass fittings!

Having proven its worth (at least in the mind of the originator(s))[^originators] the new component then begins its journey along a path of further development. This is shown by arrow going left to right in the Wardley Map. During this process the component matures, or evolves, from a working technology towards a state that is more reliable, more efficient, more robust, and in doing is often augmented in a variety of ways. For example, take a jet engine. It consists of an air intake system, a compressor system (to compress the inducted air for combustion), a combustion system (to provide high-energy gas flow for the turbine), a turbine system (to drive the compressor and provide reactive thrust), and an exhaust section.(Otis, 1997)[^otis1997]

[^originators]: Following Arthur (2007 p. 279)[^arthur2007] I will call them *originators*, to avoid the lone eccentric connotation of “inventors”.

Each of these in turn is supported, supplied, monitored and controlled by other sub-components: "the compressor system requires a variable vane actuating system (to set the vane angles appropriately to airflow velocity), and an anti-stall bleed system to control pressure surges (the tendency of the compressed air to blow backwards); the turbine system requires a blade cooling system, and a complicated set of shrouds and seals to prevent high-pressure gas leakage" (Arthur (2007 p. 277)[^arthur2007]).

The development of the component is ultimately driven by supply and demand competition in the market at later stages of maturity. We can therefore think of a component as existing it several different states over the duration of its evolution. This is illustrated in Figure 2, where we have a component in three states. The initial working technology C[1], at a previous date in the past in the Genesis stage, C[2] the current stage of the component in the present in a Product stage and finally C[3] in the future at the Commodity stage [^1].  

![Figure 2](/assets/0001_Structural_Deepening_Fig2.png)
**Figure 2. Evolution of a component from past to present through different realisations of the technology 1-3. At each stage of development the technology must be made reliable, improved, scaled up and adapted to purposes. As we move from 1-3 engineers can test better techniques, solve problems, and create performance improvements based on operating conditions.**


## Purposed systems

Before discussing the behaviour of sets of components in more detail, lets us first look briefly at the y-axis of the Wardley Map, labelled *value chain* [^4].

[^4]: There is ongoing discussion about the structure, and indeed necessity of, the y-axis in a Wardley Map. [Ref](https:link) Whilst there is still a lot to be figured out, I think of any particular map as a projection from a high-dimensional space to a lower one - and as such - the 2D map is useful and we are likely to agree in due course on a definition and measurement process for the y-avis that has broad utility - I am not in favour of getting rid of it!

As with any map, a Wardley Map is depicted at a level of abstraction (and consequent detail) to be useful for a particular task. In our case this will mean looking at sets of components of specific technologies - and in any particular map some components will be included and some omitted. At the highest level of abstraction the y-axis of the map links purposes-principles-phenomena.

However, following Arthur (Arthur 2007 [^arthur2007]) we can maintain that each component system, or *assembly* of components, itself has a purpose, a task that it is designed to carry out. If not, it would not exist.

Technologies are put together or *combined* from component parts or assemblies. We can arrange these purposed systems in chain of dependancies starting with (user) needs - the reason we created the component in the first place - at the top of the y-axis and descending through the requisit components and sub-components. It is the nature of technology, that at the end of this chain, or any terminating branch, there is always a physical effect or a phenomenon that can be exploited to satisfy it. Chains (or networks) of components are required to satisfy any suitably involved set of needs in an economy and therefore other sub-principles (and therefore sub-components) are required for its practical working.

To return to the example of the an aircraft jet engine (or gas turbine powerplant), the assembly of components exploits the phenomenon that a mass expelled backward produces an equal and opposite forward reaction. However, the phenomenon exploited at a given level of abstraction of a Map need not only be physical and "any reliable or repeatable effect from nature, or logic, or behaviour, or organisation may be harnessed for use" (ibid. pp. 276).

Therefore, we proceed from purposes, through needs and their satisficing assembly of components, to effects and phenomena. This can been seen in Figure 3. In practise, we will frequently draw a map, and its implied causal chains, at a level of abstraction that does not contain purposes and phenomena.

![Figure 3](/assets/0001_Structural_Deepening_Fig3.png)
**Figure 3. Purposed systems. Each component system, or assembly of components, itself has a purpose that can be thought of as a chain joining purposes to phenomena.**


## Focal technologies and the main assembly

Let us now turn to the question of what components to include on the map. The user need – personally or socially perceived - can be represented as a *customer* node at the top of the map. This is supported by a technology built around the exploitation of some effect, as envisaged through some principle of use.

The method for achieving the purpose, as envisaged through some *main principle* of use will be referred to as the *main assembly*. This is illustrated in Figure 4.

![Figure 4](/assets/0001_Structural_Deepening_Fig4.png)
**Figure 4. Structure of the main assembly. The customer need is supported by a constellation of components and supporting activities - demarcated with a dotted line - that link it to a underlying set phenomena and effects.**

In practice the *main assembly* refers to a core set of components (or methods) that successfully capture the base principle – plus other assemblies hung off this to support its working, regulate its function, and feed it with energy. Following Adner and Kapoor (Adner and Kapoor 2016[^adnerKapoor2016]) we identify this smallest functional component as the *focal technology* for an analysis at the level of a specific task.

This key technology is supported in turn by assemblies that require their own sub-components and sub-assemblies: controlling mechanisms, monitoring devices, input and output interfaces and so forth. We will refer to this complete set as the *main assembly*.

In general in a Wardley map, we are interested in looking at the evolution of components over time to enable us to think strategically about how they continue to provide support for a given purpsoe. But to understand the developments in the focal technologies and how they are competing for dominance we need to also consider developments in the technology in the supporting assemblies in which each of the focal technologies is embedded (Adner and Kapoor 2016[^adnerKapoor2016]).

This will allow us to draw a key distinction between the *as-developed* performance of a focal technology, which depends on the components of the focal technology and the *as-used performance* of the technology which depends additionally on the complements which users integrate with the focal technology.

## An example of Lithography

Let us look at the example of Lithography in more detail. In Figure 5 you can see the value chain for a lithography 



![Figure 5](/assets/0001_Structural_Deepening_Fig5.png)
**Figure 5. Semiconductor lithography value chain. Firms mentioned in parenthesis are only representative of the firms participating in the lithography ecosystem. Adapted from Adner & Kapoor (2016, p. 633, Figure 4)[^adnerKapoor2016]**

![Figure 6](/assets/0001_Structural_Deepening_Fig6.png)
**Figure 6. Determinants of value.**

![Figure 7](/assets/0001_Structural_Deepening_Fig7.png)
**Figure 7. Evolution of the main assembly.**

![Figure 8](/assets/0001_Structural_Deepening_Fig8.png)
**Figure 8. Evolving value "as used".**

![Figure 9](/assets/0001_Structural_Deepening_Fig9.png)
**Figure 9. Structural deepening.**

It the next post we'll look at different paths for the evolution of the main assembly to help us understand why do some new technologies emerge and quickly supplant incumbent technologies while others take years or decades to take off. We explore the framework of Adner and Kapoor (2016)[^adnerKapoor2016]that considers both the focal competing technologies as well as the ecosystems in which they are embedded.

# References

[^adnerKapoor2016]: Adner, R. and Kapoor, R., Innovation ecosystems and the pace of substitution: Re-examining technology S-curves, Strategic Management Journal, 37: 625-648, 2016

[^arthur2007]: Arthur, W. Brian, The Structure of Invention, Research Policy, 36, pages 274-287, 2007

[^arthur2009]: Arthur, W. Brian, The Nature of Technology, Penguin Books UK, 2009

[^otis1997]: Otis, 1997

[^wardley2016]: Wardley, S., Topographical intelligence in business, 2016

--


Technologies consist of parts - assemblies or sub-assemblies - that are themselves technologies. W. Brian Arthur talks about the recursive structure of technologies. In \cite{} pp. he refers to

For example, the hydroelectric power generator combines several main components: a reservoir, an intake system with control gates, an intake sluice or penstock, turbines, electricity generators driven by the turbines, transformers to convert the power output to higher voltage, and an outflow system. Arthur p.276
