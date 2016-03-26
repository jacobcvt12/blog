# libraries
library(nlme)
library(ggplot2)
library(dplyr)
library(tidyr)

# create regression parameters
beta <- c(4, 10, -5, 6)
tau.00 <- 3
sigma.2 <- 1.2

# create covariates
set.seed(1)
n <- c(500, 100, 120, 76, 800, 138, 129, 4, 67, 108, 3) # groups
g <- rep(letters[seq_len(length(n))], times=n)
x <- matrix(rnorm(sum(n) * (length(beta) - 1), mean=10, sd=12), 
            nrow=sum(n))
X <- cbind(1, x)

# get small groups to remove later
small <- names(which(table(g) < 5))
big <- which(! g %in% small)

# run simulation
set.seed(42)
iter <- 1000

# allocate memory for tracking estimates by simulation
est.all <- numeric(iter)
est.sub <- numeric(iter)
res.all <- numeric(iter)
res.sub <- numeric(iter)
int.all <- numeric(iter)
int.sub <- numeric(iter)

for (i in 1:iter) {
    # epsilon ~ norm(0, sigma.2)
    eps <- rnorm(sum(n), 0, sqrt(sigma.2))

    # beta0.rand ~ norm(beta0, tau.00 ^ 2)
    beta0.rand <- rnorm(length(n), beta[1], tau.00)

    # construct matrix for easier multiplcation of beta and X
    beta.mat <- cbind(rep(beta0.rand, times=n), beta[2], beta[3], beta[4])

    # construct y from X %*% beta + epsilon
    y <- rowSums(X * beta.mat) + eps

    # set up data frame for regression
    data <- data.frame(y, x, g)

    # run regression
    mod.all <- lme(y ~ X1 + X2 + X3, data, random=~ 1 | g)
    mod.sub <- lme(y ~ X1 + X2 + X3, data[big, ], random=~ 1 | g)
    var.all <- as.numeric(VarCorr(mod.all, sigma=mod.all$sigma))
    var.sub <- as.numeric(VarCorr(mod.sub, sigma=mod.sub$sigma))

    # store estimates
    est.all[i] <- fixef(mod.all)[1]
    est.sub[i] <- fixef(mod.sub)[1]
    res.all[i] <- var.all[2]
    res.sub[i] <- var.sub[2]
    int.all[i] <- var.all[1]
    int.sub[i] <- var.sub[1]
}

# construct datasets for visualizing
data.all <- data_frame(Estimate=est.all,
                       Residual=res.all,
                       Intercept=int.all,
                       data="all") %>%
    gather(parameter, value, Estimate:Intercept)

data.sub <- data_frame(Estimate=est.sub,
                       Residual=res.sub,
                       Intercept=int.sub,
                       data="sub") %>%
    gather(parameter, value, Estimate:Intercept)

truth.all <- data_frame(Estimate=beta[1],
                        Residual=sigma.2,
                        Intercept=tau.00 ^ 2,
                        data="all") %>%
    gather(parameter, value, Estimate:Intercept)

truth.sub <- data_frame(Estimate=beta[1],
                        Residual=sigma.2,
                        Intercept=tau.00 ^ 2,
                        data="sub") %>%
    gather(parameter, value, Estimate:Intercept)

data <- bind_rows(data.all, data.sub)
data.truth <- bind_rows(truth.all, truth.sub)

# make plot
ggplot(data, aes(x=value)) +
    geom_density(aes(colour=parameter,
                     linetype=data)) +
    geom_vline(data=data.truth, aes(xintercept=value), 
                linetype=2) +
    guides(colour=FALSE, linetype=FALSE) +
    facet_grid(parameter ~ data, scales="free") +
    xlab("") +
    ylab("") +
    theme_classic()
