---
layout: post
title:  "Comparing Choice of Priors for Variance"
date:   2016-03-17 15:27:47 -0500
comments: true
tags:
- JAGS
- Hierarchical Models
- Priors
---

In his highly cited paper, Gelman {% cite gelman2006 -A %} writes about group level variance approximation by gibbs sampler. It is noted that for a simple hierarchical model such as 

$$\begin{align}
y_{ij} & \sim \text{N}(\mu + \alpha_j, \sigma_y^2), i=1, \dots, n_j, j=1,\dots, J \\
\alpha_j & \sim \text{N}(0, \sigma_{\alpha}^2)
\end{align}$$

There is generally enough data for the prior on \\(\sigma_y^2\\) to not matter for posterior inference. However, there are often few groups *J*, and so the prior for \\(\sigma_{\alpha}^2\\) must be chosen carefully. In this post, I examine variance priors discussed in {% cite gelman2006 %}. I look at three different data sources  

1. Simulated hierarchical normal data with shared variance
2. Simulated random effects linear regression (varying slope)
3. Some other data

In the two simulated data sources, I examine group sizes of 3, 10, and 25. The analysis is conducted using JAGS {% cite plummer2003 %}. For the simulation data, the truth is known. Model fit in 3. is compared via DIC {% cite spiegelhalter2002 %}.


# Simulation

![Simple Simulation](/assets/img/variance-sim-1.svg)

# Priors

# Analysis and Comparison

# References

{% bibliography --cited %}
