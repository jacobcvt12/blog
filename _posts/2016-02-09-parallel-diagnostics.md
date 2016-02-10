---
layout: post
title:  "Parallel Rcpp for MCMC diagnostics"
date:   2016-02-09 17:32:47 -0500
categories: Parallel, Gibbs Sampling, Computing, Diagnostics, Rcpp
---

Many Bayesian diagnostics require multiple chains to assess convergence. A common estimator is the Gelman-Rubin diagnostic. Note that this diagnostic requires that the parameter in question must be *approximately normal*. This method assesses convergence by parameter and method of estiamtion (Gibbs, Metropolis-Hastings, etc) does not matter.

For a given parameter, we calulate the variance by parameter (MCMC iteration *i* and chain *j*).

$$s_j^2 = \frac{1}{n-1}\sum_i^n(\theta_{ij}-\bar{\theta}_j)^2$$

The within chain variance is simply the mean of these variances or

$$W=\frac{1}{m}\sum_i^m s_j^2$$

The between chain variance is calculated as 

$$B=\frac{m}{n-1}\sum_1^m (\bar{\theta}_j-\bar{\bar{\theta}})^2$$

where $$\bar{\bar{\theta}}=\frac{1}{m}\sum_i^m \bar{\theta}_j$$

Or more simply is the "mean of means."


{% highlight R %}
print(2+2)
{% endhighlight %}

Check out the [Parallel Example package][RcppParallel] for implementation details.

[RcppParallel]: https://github.com/jacobcvt12/RcppParallelExample
