---
layout: post
title:  "Parallel Rcpp for MCMC diagnostics"
date:   2016-02-09 17:32:47 -0500
categories: Parallel, Gibbs Sampling, Computing, Diagnostics, Rcpp
---

Many Bayesian diagnostics require multiple chains to assess convergence. A common estimator is the Gelman-Rubin diagnostic {% cite gelman1992 %}. Note that this diagnostic requires that the parameter in question must be *approximately normal*. This method assesses convergence by parameter and method of estiamtion (Gibbs, Metropolis-Hastings, etc) does not matter.

For a given parameter, we calulate the variance by parameter (MCMC iteration *i* and chain *j*).

$$s_j^2 = \frac{1}{n-1}\sum_i^n(\theta_{ij}-\bar{\theta}_j)^2$$

The within chain variance is simply the mean of these variances or

$$W=\frac{1}{m}\sum_i^m s_j^2$$

The between chain variance is calculated as 

$$B=\frac{m}{n-1}\sum_1^m (\bar{\theta}_j-\bar{\bar{\theta}})^2$$

where $$\bar{\bar{\theta}}=\frac{1}{m}\sum_i^m \bar{\theta}_j$$

Or more simply is the "mean of means."

For a univariate parameter, it is appropriate to use a matrix to handle multple MCMC chains of samples from the stationary distribution. Consider the columns to be individual chains and the rows to represent MCMC samples. The following is an R function to calculate the Gelman-Rubin diagnostic of a parameter stored in such a fashion.

{% highlight R %}
gelman.rubin <- function(param) {
    # mcmc information
    n <- nrow(param) # number of iterations
    m <- ncol(param) # number of chains

    # calculate the mean of the means
    theta.bar.bar <- mean(colMeans(param))

    # within chain variance
    W <- mean(apply(param, 2, var))

    # between chain variance
    B <- n / (m - 1) * sum((colMeans(param) - theta.bar.bar) ^ 2)

    # variance of stationary distribution
    theta.var.hat <- (1 - 1 / n) * W + 1 / n * B

    # Potential Scale Reduction Factor (PSRF)
    R.hat <- sqrt(theta.var.hat / W)

    return(R.hat)
}
{% endhighlight %}

Check out the [Parallel Example package][RcppParallel] for implementation details.

{% bibliography --cited %}

[RcppParallel]: https://github.com/jacobcvt12/RcppParallelExample
