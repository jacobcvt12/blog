# simulate data for prior variance
set.seed(1)
n.i <- 100

## simple hierarchical model
mu <- 15
s.y2 <- 1
s.a2 <- 20
n.j <- c(3, 10, 25)

alpha.j <- lapply(n.j, function(n) rnorm(n, 0, sqrt(s.a2)))
y.ij <- lapply(alpha.j, function(alpha) { rnorm(n.i * length(alpha), 
                                                mu + alpha,
                                                sqrt(s.y2)) })

library(dplyr)
data <- bind_rows(data_frame(y=y.ij[[1]], 
                             g=rep(seq_len(n.j[1]), n.i),
                             mu=rep(mu + alpha.j[[1]], n.i),
                             n=n.j[1]),
                  data_frame(y=y.ij[[2]], 
                             g=rep(seq_len(n.j[2]), n.i),
                             mu=rep(mu + alpha.j[[2]], n.i),
                             n=n.j[2]),
                  data_frame(y=y.ij[[3]],
                             g=rep(seq_len(n.j[3]), n.i),
                             mu=rep(mu + alpha.j[[3]], n.i),
                             n=n.j[3])) %>%
    mutate(n=factor(n, levels=n.j))

library(ggplot2)
ggplot(data, aes(y)) +
    geom_density(aes(colour=n)) +
    geom_rug(aes(x=mu)) +
    facet_wrap(~n) +
    ylab("") +
    guides(colour=FALSE) +
    theme_classic()
