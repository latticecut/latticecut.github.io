---
layout: post
title: "Structural Deepening"
date: 2019-09-22
---

***

## Preamble

I have been intending to write a blog for some time.

This is to help me better understand my own ideas about the papers I read, talks I hear, and increasingly important, the social media threads I view.

As such, most of the material on this blog is just a reworking of other peoples ideas, perhaps in a different context, or with comparisons drawn with the work of others. I hope it is all referenced correctly. To this end, I am interested in feedback and input on clarifications, corrections, errata, emendations and so forth.

I currently work in different fields, from machine learning (ML), to law, and in different contexts from graduate education to tech startups. This blog is focused on my interest in the different mechanisms of invention, innovation and the evolution of technology. Most of my recent discussions in these matter have been with Dr Dave Chapman at the UCL School of Management where I teach courses on designing predictive systems (ML) and technology strategy.

In particular, I'm interested in a examining aspects of Simon Wardley's mapping framework[^wardley2016] in greater detail. Most of these early posts are going to be about interpreting some of the other works in the (predominantly management science) literature in the context of a map.

For those of you that don't know the background to this, you can begin reading [On being lost](https://medium.com/wardleymaps/on-being-lost-2ef5f05eb1ec) to learn more about it. Reading Chapters 2 and 3 with takes about an hour.

To me, the appeal of this mapping framework is that it views a business (model) as a directed graph in a metric (or ordinal) space - I think this has lots of advantages over other things we commonly refer to as business models - but more on that at a later date.

***

# The structure of invention

These series of posts are about the evolution of technologies, and the transitions between competing technologies in the context of a business.

In future posts, this will touch on subjects such as *technical debt* and *obsolescence* but to start with I want to introduce some terminology. This first post draws heavily on the work of W. Brian Arthur with referenced papers at the bottom of the page.

The x-axis of a Wardley Map (Figure 1 below) displays the maturity of a technology over its life cycle. The maturity is divided into four stages; Genesis, Custom Build, Product, Utility[^stages].

[^stages]: Following [Wardley 2016](https://medium.com/wardleymaps/finding-a-new-purpose-8c60c9484d3b), Figure 76, it is in principle possible to measure the stage of maturity of a component by assessing the language used to describe the technology in the various corpora that refer to it. From academic publications, to patents in the Genesis stage, to technical standards documentation in the early Product stage and finally to marketing collateral, sales manuals and so forth at different stages of commercial development. Not all components need pass through every stage of development. This is assumed as given for now, and I will write more on this in future posts.

To start with, illustrated in Figure 1, we can see that a component moves from left to right as it matures. I will use the word *technology* and *component* interchangeably in this blog simply as a means to fulfill a purpose[^techdef].


[^techdef]: Following Arthur (2007 p. 276)[^arthur2007]  The word technology has two other legitimate meanings: a body of practices and components, and “the totality of the means employed by a people to provide itself with the objects of material culture (Arthur, 2007, p. 276)[^arthur2007].


Initially, on the lefthand side in the *Genesis stage* the component has to be created for the first time. What is being sought at this stage is not a full design, not a full architecture, along with all the components and sub-components and a detailed understanding of its operating conditions.

What is being sought is a base concept – or in the words of Arthur a *principle* – that demonstration how we can create something new that takes us closer to achieving a desired purpose.

Here a *principle* refers to the idea of the use of a phenomenon for some purpose.(ibid. p. 2007)

![Figure 1](/assets/0001_Structural_Deepening_Fig01.png)
**Figure 1. Map showing the evolution of a component through 4 stages, from Genesis to Commodity.**


At the Genesis stage, a new component might have been *kludged* together from existing components or assemblies of existing components - a minimum viable prototype [MVP](https://) if you will. For example, according to Arthur (2009 p. 131)[^arthur2009], Lawrence's first [cyclotron](https://en.wikipedia.org/wiki/Cyclotron) was assembled from parts that included a kitchen chair, a clothes tree, window glass, sealing wax and brass fittings!

Having proven its worth (at least in the mind of the originator(s))[^originators] the new component then begins its journey along a path of further development. This is shown by arrow going left to right in the Wardley Map. During this process the component matures, or evolves, from a working technology towards a state that is more reliable, more efficient, more robust, and a better understanding of the cost of delivery. On this journey the component technology is often augmented in a variety of ways.

Consider the example of a jet engine. It consists of an air intake system, a compressor system (to compress the inducted air for combustion), a combustion system (to provide high-energy gas flow for the turbine), a turbine system (to drive the compressor and provide reactive thrust), and an exhaust section.(Otis, 1997)[^otis1997]

[^originators]: Following Arthur (2007 p. 279)[^arthur2007] I will call them *originators*, to avoid the lone eccentric connotation of “inventors”.

Each of these in turn is supported, supplied, monitored and controlled by other sub-components: "the compressor system requires a variable vane actuating system (to set the vane angles appropriately to airflow velocity), and an anti-stall bleed system to control pressure surges (the tendency of the compressed air to blow backwards); the turbine system requires a blade cooling system, and a complicated set of shrouds and seals to prevent high-pressure gas leakage" (Arthur (2007 p. 277)[^arthur2007]).

The development (or evolution) of the component is ultimately driven by supply and demand competition in the market at different stages of maturity. We can therefore think of a component as existing in several different states over the duration of its evolution. This is illustrated in Figure 2, where we have shown a component in three states during its life-cycle.

![Figure 2](/assets/0001_Structural_Deepening_Fig02.png)
**Figure 2. Evolution of a component from past to present to future through different realisations of the technology C[1] to C[3]. At each stage of development the technology must be made reliable, improved, scaled up and adapted to purposes. As we move from states 1-3, engineers can test better techniques, solve encountered problems, and create performance improvements based on different operating conditions.**

The initial working technology is in state C[1], at a previous time in the Genesis stage, C[2] is the current stage of the component in a Product stage and finally C[3] is an anticipated future stage in the Commodity stage [^stages].  

## Purposed systems

Before discussing the behaviour of sets of components in more detail, lets us first look briefly at the y-axis of the Wardley Map, labelled *value chain* [^yaxis].

[^yaxis]: There is ongoing discussion about the structure, and indeed necessity of, the y-axis in a Wardley Map. [Ref](https:link) Whilst there is still a lot to be figured out (and this post skips over lot of nuances) I think of any particular map as a projection from a high-dimensional space to a lower one. Most commonly from 3D world to 2D map. Thinking of the 2D Wardley map as a projection into a lower dimensional space is useful - and we are likely to agree in due course on a definition and measurement process for a y-axis (or potentially multiple axes) that has broad utility - I am not in favour of getting rid of it!

As with any real world map, a Wardley Map is depicted at a level of abstraction (and consequent level of detail) to be useful for a particular task.

For our purposes, this will mean looking at sets of components of specific technologies - and in any particular map some components will be included and some omitted. At the highest level of abstraction the y-axis of the map can be thought of as linking purposes, to principles, to phenomena.

However, following Arthur (Arthur 2007 [^arthur2007]) we can maintain that each component system, or *assembly* of components, itself has a purpose, a task that it is designed to carry out. If not, it would not exist.

Consequently, technologies are put together or *combined* from component parts or assemblies[^recursive]. We can arrange these purposed systems in chain of dependancies starting with (user) needs - the reason we created the component in the first place - at the top of the y-axis and descend through the requisit components and sub-components. It is the nature of technology that, at the end of this chain (or terminating branch) there is always a physical effect or a phenomenon that can be exploited to satisfy it.

Chains (or networks, or graphs) of components are required to satisfy any suitably involved set of needs in an economy and therefore other sub-principles (and therefore sub-components) are required for a technology's practical working.

[^recursive]: W. Brian Arthur talks about the recursive structure of technologies, such that technologies consist of parts - assemblies or sub-assemblies - that are themselves technologies.

To return to the example of the jet engine, the assembly of components exploits the phenomenon that a mass expelled backward produces an equal and opposite forward reaction. However, the phenomenon exploited at a given level of abstraction of a map need not only be physical and "any reliable or repeatable effect from nature, or logic, or behaviour, or organisation may be harnessed for use" (ibid. pp. 276).

Therefore, as we descend on the y-axis we proceed from purposes, through needs and their satisficing assembly of components, to effects and phenomena. This can been seen in Figure 3.

![Figure 3](/assets/0001_Structural_Deepening_Fig03.png)
**Figure 3. Purposed systems. Each component system, or assembly of components, itself has a purpose that can be thought of as a chain joining purposes to a principle to phenomena. Supporting activities and practices are included on the key for completeness but not shown.**

In practise, we will frequently draw a map at a level of abstraction that does not contain purposes and phenomena (and their implied causal dependancies), but focuses on a small set of components.


## Focal technologies and the main assembly

Let us now turn to the question of what components to include on the map. The user *need* – personally or socially perceived - can be represented as a *customer* node at the top of the map. This is supported by a technology designed around the exploitation of some effect, as envisaged through some principle of use.

The method for achieving the purpose, as envisaged through some *main principle* of use will be referred to as the *main assembly*. This is illustrated in Figure 4.

![Figure 4](/assets/0001_Structural_Deepening_Fig04.png)
**Figure 4. Structure of the main assembly. The customer need is supported by a constellation of components and supporting activities - demarcated with a dotted line - that link it to a underlying set phenomena and effects.**

In practice the *main assembly* refers to a core set of components (or methods and activities) that successfully achieve the purpose – plus other assemblies hung off this to support its working, regulate its function, and feed it with energy. Following Adner and Kapoor (Adner and Kapoor 2016[^adnerKapoor2016]) we identify this smallest functional component as the *focal technology*. This allows us to focus a map at the level of a specific task.

The focal technology is supported in turn by assemblies that require their own sub-components and sub-assemblies: controlling mechanisms, monitoring devices, input and output interfaces and so forth. We will refer to this complete set as the *main assembly*.

In general in a Wardley map, we are interested in looking at the evolution of components over time to enable us to think strategically about how they continue to provide support for a given purpose. But to understand the developments in a focal technology and how different technologies compete for dominance we need to also consider developments in the technologies in the main assembly in which each of the focal technologies is embedded (Adner and Kapoor 2016[^adnerKapoor2016]).

In some examples, the complementary components are integral to the device itself, for example in the case of the jet engine. In other cases, the components are external to a device but form part of the operating context or wider environment. Take the case of the alternatives to the use of the internal combustion engine for the car. Fuel cells, or similar, will not pose a real substitute until they are augmented by sufficiently rich set of complementary components that constitute a developed hydrogen infrastructure.

Considering the focal technology and the main assembly will allow us to draw a key distinction between the *as-developed* performance of a focal technology, and the *as-used performance* of the technology which depends additionally on the components which must co-develop to integrate as part of the main assembly.

## An example of photo lithography

Let us look at the example of semiconductor photolithography in more detail, taken from Adner and Kapoor (Adner and Kapoor 2016[^adnerKapoor2016]). [Photolithography](https://en.wikipedia.org/wiki/Photolithography) is the process by which a circuit design is imprinted on a semiconductor substrate called a wafer.

In Figure 5 you can see the value chain for photolithography tooling[^toolchain]. The *main principle* of lithography is to use light to transfer a geometric pattern from a photomask (also called an optical mask) to a photosensitive (that is, light-sensitive) chemical photoresist on the substrate. "The lithography process takes place when beams of energy originating from an “energy source” are directed onto the mask. The pattern on the mask allows a portion of the energy beams to pass through, with or without an optical “lens” system, onto the wafer. The wafer is coated with an energy sensitive “resist.” The resist undergoes a chemical reaction wherever the mask has allowed the energy to pass through. This chemical reaction changes the structure of the resist and allows its selective removal from the wafer. Another chemical process is then initiated in which the exposed parts of the wafer are etched. Finally, the remaining resist is removed, creating a final circuit that replicates the initial design."(ibid. p.632 [^adnerKapoor2016])

[^toolchain]: In practise, a semiconductor manufacturer may use scores of photolithography tools in a single production line, potentially costing tens of millions dollars each in a modern industrial setup.

![Figure 5](/assets/0001_Structural_Deepening_Fig05.png)
**Figure 5. Semiconductor lithography value chain. Firms mentioned in parenthesis are only representative of the firms participating in the lithography ecosystem. Adapted from Adner & Kapoor (2016, p. 633, Figure 4)[^adnerKapoor2016]**

The component used to aligning the lens and the energy source is referred to at the "lithography tool" which integrates with the mask and resist to create the main assembly. This can be seen in Figure 6. Tool manufacturers and their customers, the semi-conductor manufacturers, integrate these components to produce semiconductor chips for the device manufacturer, the end customer in this map.


![Figure 6](/assets/0001_Structural_Deepening_Fig06.png)
**Figure 6. Main assembly and focal technology**


In this post we will not pay attention to the detail of the distribution (along the x-axis) of components that make up the main assembly - rather we will focus on the evolution of the main assembly itself from left to right in a manner similar to a single component illustrated in Figure 2.

In Figure 7, we illustrate the evolution of the main assembly. We can see that it goes through a series of states A[1] to A[7] across the different stages of maturity. In the earliest version of the technology, A[1], we have a working version that links purpose with phenomena. However once development of the technology has got underway, different versions emerge. Some may come from the key technologies originators (e.g. A[2]), but initial progress attracts other groups of engineers into the filed, some possibly from labs or new startups that begin to tinker with the main assembly, for example A[3]. With further maturation the technology begins to exhibit variations in deployed solutions and the assembly is subject to usual selection pressures of supply and demand. "The many versions of a technology improve in small steps by the selection of better solutions to their internal design problems... Technologies become more complex - often much more complex - as they mature." Arthur (2009 p.132)[^arthur2009].

This process of increasing complexity is illustrated on the map with a node (with a dotted edge) that expands as the components in the main assembly increase in number and complexity. For example, think back to the jet engine with he addition of variable vane actuating system and an anti-stall bleed system as the engine main assembly increases in complexity.


![Figure 7](/assets/0001_Structural_Deepening_Fig07.png)
**Figure 7. Evolution of the main assembly.**

## Structure deepening

One mechanism for this increasing complexity is *structural deepening* where the performance limitations of the original *main principle* are overcome with the addition of other sub-principles (and therefore sub-components) to improve the envelop of the technology's practical performance. One example of the physical limitations that the principle of lithography imposes is that as "developers press integrated circuits to become denser, therefore accommodating more [gates and logic]... at some point the process that produces them... becomes limited by the wavelength of light." (ibid p.133)[^arthur2009] Adding sub-systems to work around such limitations drives technologies to elaborate as they evolve - and as sub-systems or assemblies themselves are technologies, and they too develop so they enhance overall performance.

Alternatively, reverting back to the example of the jet engine, as the engines are pushed to perform at higher temperatures the turbine blades soften as temperatures rise, so a component is added to create new airflow to cool the blades or a component that circulates a cooling material inside the blades themselves.  

In complex interconnected, interdependent, economies an ongoing source of improvement is that many sub-components are shared across different main assemblies, and therefore a great deal of development happens as components evolve in other adjacent assemblies.

### Proximal value

Now, we need to return briefly to the y-axis and think about the position of main-assembly as it evolves.

We have said that the y-axis of a Wardley Map displays the chain joining purposes to a principle to phenomena. In the same way that time is implicitly normalised[^stages] at the level of an individual component in the x-axis (so that components at the same stage of maturity have perhaps existed for very different periods of time) a similar mechanism can be used for the relative positioning of components on the y-axis.

Wardley sets out this notion as one of *visibility*. Components that are closer, or more visible, appear at the top of the map.  

The first thing to note is that serve a new purpose, or exploit a new principle, tend to appear higher on the axis.  

A map can be altered to the viewpoint of...



broadly speaking components appear on the top right of the map and transition as they evolve to the bottom right. The details dynamics and trajectories in the map, an patterns of behaviour, are our interest in the context of decision making and strategy.

value as a graph traversal problem

We are now in a position to revisit the distinction between the *as-developed* performance of a focal technology, and the *as-used performance* of the evolving assembly. However, to do so we need to


![Figure 8](/assets/0001_Structural_Deepening_Fig08.png)
**Figure 8. Higher order systems. As a system moves towards later stages of maturity, it can become as supporting component for a higher order system. Here the ubiquity of A[7], with potential increase in availability and reduction in cost of consumption, enables the creation of a new component B.**

*basically not going to get away without going back to y-axis here*

*visibility as proxy for value*
*high order components built 'ontop' of others*

Implicitly, a higher order component is created, or revisited, at a later time

![Figure 9](/assets/0001_Structural_Deepening_Fig09.png)
**Figure 9. Proximal value.**

In Figure 9, we can see

![Figure 10](/assets/0001_Structural_Deepening_Fig10.png)
**Figure 10. Determinates of value.**

![Figure 11](/assets/0001_Structural_Deepening_Fig11.png)
**Figure 11. Structural deepening.**

It the next post we'll look at different paths for the evolution of the main assembly to help us understand why some new technologies emerge and quickly supplant incumbent technologies while others take years or decades to take off.

We'll explore the framework of Adner and Kapoor (2016)[^adnerKapoor2016] that considers the co-evolution of competing focal technologies as well as assemblies in which they are embedded.

# References

[^adnerKapoor2016]: Adner, R. and Kapoor, R., Innovation ecosystems and the pace of substitution: Re-examining technology S-curves, Strategic Management Journal, 37: 625-648, 2016

[^arthur2007]: Arthur, W. Brian, The Structure of Invention, Research Policy, 36, pages 274-287, 2007

[^arthur2009]: Arthur, W. Brian, The Nature of Technology, Penguin Books UK, 2009

[^otis1997]: Otis, 1997

[^wardley2016]: Wardley, S., Topographical intelligence in business, 2016

---
