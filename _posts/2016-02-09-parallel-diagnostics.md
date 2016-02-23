---
layout: post
title:  "Parallel Rcpp for MCMC diagnostics"
date:   2016-02-09 17:32:47 -0500
tags:
- Parallel
- Gibbs Sampling
- Computing
- Diagnostics
- Rcpp
---

![Hypothetical Multiple MCMC Chains](/assets/img/multi-chains.jpg)

A common question in Bayesian statistics and Markov Chain Monte Carlo is the concept of convergence. When approximating parameters by MCMC, we expect the chains to converge to the *stationary distributions*. Visual inspection of a traceplot of values of a MCMC can suggest convergence. A more robust solution is to use *multiple chains*. The idea here is that if multiple chains appear to have arrived at the same distribution, then we can be more certain of convergence. 

One of the key challenges here is that MCMC simulations must be run iteratively, and are often computationally intensive. Even if you use a compiled language for your sampler, running two or three chains sequentially will double or triple what may already be a lengthy process. In this post, I show how to use open-MP for *parallelizing* MCMC simulations. After doing so, the same code with 2-3 chains will likely only take slightly longer than one chain.

# Convergence Criteria

There are several diagnostics for quantifying convergence, but the most commonly used one is the Gelman-Rubin diagnostic {% cite gelman1992 %}. Note that this diagnostic requires that the parameter in question must be *approximately normal*. 

Convergence is assessed by parameter (parameter $\theta$ may have converged, but $\mu$ may not have). Here *i* indicates the MCMC iteration, and *j* indicates the chain number. Note that the *burn-in* portion of a MCMC simulation is not included in the calculation of this diagnostic.

First, the variance of a single chain of a parameter is calculated

$$s_j^2 = \frac{1}{n-1}\sum_i^n(\theta_{ij}-\bar{\theta}_j)^2$$

The within chain variance is simply the mean of these variances or

$$W=\frac{1}{m}\sum_i^m s_j^2$$

The between chain variance is calculated as 

$$B=\frac{m}{n-1}\sum_1^m (\bar{\theta}_j-\bar{\bar{\theta}})^2$$

where $$\bar{\bar{\theta}}=\frac{1}{m}\sum_i^m \bar{\theta}_j$$

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

A parameter is usually considered converged when the Gelman-Rubin statistic is $$<1.1$$. If your parameter has not converged, this can usually be fixed by increasing the number of burnin iterations.

Check out the [Parallel Example package][RcppParallel] for implementation details.

# Parallel Chains

Since this diagnostic requires multiple chains, a typical solution is to run the chains in parallel. Since sampling MCMC is computationally intensive, we typically write sampler in compiled language. Here I use C++ in combination with the Rcpp {% cite eddelbuettel2011 %} library for the compiled language and Open-MP for parallelization.

{% highlight C++ %}
#include <RcppArmadillo.h>
#include <cmath>
#include <omp.h>

// [[Rcpp::export]]
Rcpp::List normal_gibbs(arma::vec data, double mu0, double t20, double nu0, double s20, 
                        int burnin=1000, int iter=1000, int chains=1) {
    // initialize parameters
    double data_mean = arma::mean(data);
    double data_var = arma::var(data);
    int n = data.size();
    double mu = data_mean;
    double s2 = data_var;

    // initialize chains
    arma::mat mu_chain(iter, chains);
    arma::mat s2_chain(iter, chains);

    #pragma omp parallel for num_threads(chains)
    for (int chain = 0; chain < chains; ++chain) {
        // burnin
        for (int b = 0; b < burnin; ++b) {
            // update mu
            double mu_n = (mu0 / t20 + n * data_mean * (1. / s2)) / (1. / t20 + n * (1 / s2));
            double t2_n = 1 / (1 / t20 + n / (s2));
            mu = arma::conv_to<double>::from(rnormArma(1, mu_n, t2_n));

            // update s2
            double nu_n = nu0 + n;
            double s2_n = (nu0 * s20 + (n-1) * data_var + n * pow(data_mean - mu, 2)) / nu_n;
            s2 = arma::conv_to<double>::from(arma::randg(1, arma::distr_param(nu_n / 2., 2. / (nu_n *s2_n))));
        }

        // sample from stationary distribution
        for (int s = 0; s < iter; ++s) {
            // update mu
            double mu_n = (mu0 / t20 + n * data_mean * (1. / s2)) / (1. / t20 + n * (1 / s2));
            double t2_n = 1 / (1 / t20 + n / (s2));
            mu = arma::conv_to<double>::from(rnormArma(1, mu_n, t2_n));

            // update s2
            double nu_n = nu0 + n;
            double s2_n = (nu0 * s20 + (n-1) * data_var + n * pow(data_mean - mu, 2)) / nu_n;
            s2 = 1. / arma::conv_to<double>::from(arma::randg(1, arma::distr_param(nu_n / 2., 2. / (nu_n *s2_n))));

            // store values
            mu_chain(s, chain) = mu;
            s2_chain(s, chain) = s2;
        }
    }


    return Rcpp::List::create(Rcpp::Named("mu")=mu_chain,
                              Rcpp::Named("s2")=s2_chain);
}

{% endhighlight %}

To add the openmp flag to the compiler, add the following two lines to your `src/Makevars` file

{% highlight Make %}
PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS) -fopenmp
PKG_LIBS = $(SHLIB_OPENMP_CXXFLAGS) -fopenmp
{% endhighlight %}

Some caveats: not every compiler supports openmp. For example, the default `clang` compiler on OS X will not compile the above code. An alternative is to use `gcc` via [homebrew][homebrew-site] installed with the command `brew install gcc --without-multilib`. On most linux distributions, `gcc` should compile C++ with open-MP without additional configuration.

# Results

To investigate performance of parallel chains using open-MP, I simulated data from a normal distribution with 1,000, 10,000, 100,000, and 1,000,000 observations and benchmarked the above code with 1,000 iterations and 1,000 burnins. Below is a density plot of the timings (in milliseconds) by chain number as well as number of observations in the simulated data.

![Multiple MCMC Chains Timings](/assets/img/multi-chains-timings.jpg)

While there is some overhead with adding an additional thread, going from 1 to 2 chains and 3 to 4 chains is mostly negligible. A more computationally intensive model would demonstrate the time savings of using open-MP for parallel chains even further.

For an additional example of open-MP for parallel MCMC chains see [this Mixture Model package][RcppMixtureModel].

# References

{% bibliography --cited %}

[RcppParallel]: https://github.com/jacobcvt12/RcppParallelExample
[RcppMixtureModel]: https://github.com/jacobcvt12/RcppMixtureModel
[homebrew-site]: http://brew.sh
