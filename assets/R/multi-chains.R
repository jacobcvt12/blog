# code to generate fake multiple MCMC chains
library(ggplot2)
set.seed(1)

burnin <- 500
stat.samples <- 500
true.mean <- 12
chain.1.burn.mean <- seq(-10, true.mean, len=burnin)
chain.2.burn.mean <- seq(-2, true.mean, len=burnin)
chain.3.burn.mean <- seq(25, true.mean, len=burnin)

# sample burnin and stationary
chain.1 <- c(rnorm(burnin, chain.1.burn.mean, 2.5), rnorm(stat.samples, true.mean, 2.5))
chain.2 <- c(rnorm(burnin, chain.2.burn.mean, 2.5), rnorm(stat.samples, true.mean, 2.5))
chain.3 <- c(rnorm(burnin, chain.3.burn.mean, 2.5), rnorm(stat.samples, true.mean, 2.5))

iter <- 1:(burnin+stat.samples)

# bind data together
data <- rbind(data.frame(iter=iter, theta=chain.1, chain="1"),
              data.frame(iter=iter, theta=chain.2, chain="2"),
              data.frame(iter=iter, theta=chain.3, chain="3"))

# plot data
jpeg("../img/multi-chains.jpg")
ggplot(data, aes(x=iter, y=theta)) +
    geom_line(aes(colour=chain, linetype=chain)) +
    xlab("") +
    ylab(expression(theta)) +
    guides(colour=FALSE, linetype=FALSE) +
    theme_classic()
dev.off()
