library(microbenchmark)
library(RcppParallelExample)
library(dplyr)
library(ggplot2)

# set seed
set.seed(1)

# generate data
mu.true <- 20
s2.true <- 9
data <- rnorm(5000, mu.true, sqrt(s2.true))

# run gibbs sampler
suppressMessages(
time <- microbenchmark(
    normal.gibbs(data, chains=1),
    normal.gibbs(data, chains=2),
    normal.gibbs(data, chains=3),
    normal.gibbs(data, chains=4)
)
)

data <- as.data.frame(time) %>%
    mutate(time=time/1e6) # time in milliseconds
