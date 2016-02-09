---
layout: post
title:  "Parallel Rcpp for MCMC diagnostics"
date:   2016-02-09 09:32:47 -0500
categories: Parallel, Gibbs Sampling, Computing, Diagnostics, Rcpp
---

Many Bayesian diagnostics require multiple chains to assess convergence. A common estimator is the Gelman-Rubin diagnostic. Note that this diagnostic requires that the parameter in question must be *approximately normal*. This method assesses convergence by parameter and method of estiamtion (Gibbs, Metropolis-Hastings, etc) does not matter.

For a given parameter, we calulate the variance by parameter

$$s_j^2 = \frac{1}{n-1}\sum_i^n(\theta_{ij}-\bar{\theta}_j)^2$$

{% highlight R %}
print(2+2)
{% endhighlight %}

Check out the [Parallel Example package][RcppParallel] for implementation details.

[RcppParallel]: https://github.com/jacobcvt12/RcppParallelExample
