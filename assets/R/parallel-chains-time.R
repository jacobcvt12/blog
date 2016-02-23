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
for (n in c(1000, 10000, 100000, 1000000)) {
data <- rnorm(n, mu.true, sqrt(s2.true))
time <- microbenchmark(
    normal.gibbs(data, chains=1),
    normal.gibbs(data, chains=2),
    normal.gibbs(data, chains=3),
    normal.gibbs(data, chains=4)
)
timing.data <- as.data.frame(time) %>%
    mutate(`length(y)`=formatC(n, format="d", big.mark=",")) %>%
    bind_rows(timing.data)
}
)

timing.data <- timing.data %>%
    mutate(time=time/1e6, # time in milliseconds
           expr.char=as.character(expr),
           `length(y)`=factor(`length(y)`, 
                              levels=c("1,000", "10,000",
                                       "100,000", "1,000,000")),
           chains=substr(expr.char, nchar(expr.char)-1, 
                         nchar(expr.char)-1)) %>%
    select(-expr, -expr.char) %>%
    group_by(chains, `length(y)`) %>%
    filter(abs(time - median(time)) < 2 * sd(time)) %>%
    ungroup()

jpeg("../img/multi-chains-timings.jpg")
ggplot(timing.data, aes(x=chains, y=time)) +
    geom_violin(aes(colour=chains), draw_quantiles=0.5) +
    facet_wrap(~`length(y)`) +
    guides(colour=FALSE) +
    theme_classic()
dev.off()
