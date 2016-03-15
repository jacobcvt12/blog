# simulate data for prior variance
set.seed(1)
n.i <- 100

## simple hierarchical model
mu <- 15
s.y2 <- 5
s.a2 <- 20
n.j <- c(3, 10, 25)

y.ij <- lapply(n.j, function(n) { rnorm(n.i * n, 
                                        mu + rnorm(n, 0, sqrt(s.a2)),
                                        sqrt(s.y2)) })
y <- y.ij[[1]]
g <- rep(1:3, n.i)
d=data.frame(y, g)
summarise(group_by(d, g), mean=mean(y))
plot(density(y))
