library(microbenchmark)
devtools::load_all("~/Code/rcpp-parallel")
library(dplyr)
library(ggplot2)

# set seed
set.seed(1)

# generate data
mu.true <- 20
s2.true <- 9

# empty timing dataset
timing.data <- data_frame()

# run gibbs sampler
suppressMessages(
for (n in c(100, 1000, 10000, 100000)) {
data <- rnorm(n, mu.true, sqrt(s2.true))
time <- microbenchmark(
    normal.gibbs(data, chains=1),
    normal.gibbs(data, chains=2),
    normal.gibbs(data, chains=3),
    normal.gibbs(data, chains=4)
)
timing.data <- as.data.frame(time) %>%
    mutate(`length(y)`=n) %>%
    bind_rows(timing.data)
}
)

data <- timing.data %>%
    mutate(time=time/1e6, # time in milliseconds
           expr.char=as.character(expr),
           chains=substr(expr.char, nchar(expr.char)-1, 
                         nchar(expr.char)-1)) %>%
    select(-expr, -expr.char)

ggplot(data, aes(x=chains, y=time)) +
    geom_violin() +
    facet_wrap(~`length(y)`, scales="free_y")
