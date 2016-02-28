---
layout: post
title:  "Creating Hierarchical Model Diagrams with LaTeX"
date:   2016-02-26 15:27:47 -0500
comments: true
tags:
- LaTeX
- Hierarchical Models
---

Bayesian models are often considered in a hierarchical fashion. Even when there is no multilevel structure to the data, the model can still be implicitly hierarchical due to the relationship of hyperparameters, parameters of interest, and data.

For a simple hierarchical Bayesian model, the structure can be written as a series of random variables and the distributions which they follow. For example, the number of cases of pancreatic cancer may have been collected by county (with hypothetically standardized population sizes). A possible model with a Poisson likelihood, a Gamma prior on the mean pancreatic cases and hyperparameters *a* and *b*.

$$\begin{align}
y_i & \sim \text{Poisson}(\theta) \\
\theta & \sim \text{Gamma}(a, b)
\end{align}$$

For complicated hierarchical models, it may be more easily communicated through a graphical diagram instead of - or in addition to - the description above.

![Just number](/assets/img/hierarchical-comparison.svg)

# Ti*k*Z and diagrams for hierarchical models

A popular \\(\LaTeX\\) package for creating images and diagrams is Ti*k*Z {% cite tantau2013 %}. Ti*k*Z can be used in many different ways to create a diagram. However, some methods are more difficult than others. I have found the `matrix` library within Ti*k*Z to provide the simplest approach, with the least amount of "archane" looking code.

The general structure of using the `matrix` library with the Ti*k*Z package is

{% highlight TeX %}
\documentclass{article}
\usepackage{tikz}
\usepackage{amsmath} 
\usetikzlibrary{matrix} % note this is in the preamble
\begin{document}

\begin{tikzpicture}

% diagram here

\end{tikzpicture}
\end{document}
{% endhighlight %}

First, a very basic Ti*k*Z matrix looks like a typical linear algebra matrix. A matrix is specified using `\matrix` followed by options of the matrix and the name of the matrix (here chosen to be mat). Cells on the same row are separated by `&`'s, and new rows are begun by `\\`. Of note, if one row has more columns than the others (more `&`'s), then the other rows will have more columns implicitly added to match.

{% highlight TeX %}
\matrix[matrix of nodes] (mat)
{
    1 & 2 & 3 \\
    4 & 5 & 6 \\
    7 & 8 & 9 \\
};
{% endhighlight %}

![Just number](/assets/img/hierarchical-graph-1.svg)

For this matrix to look anything like a hierarchical diagram, we first need to replace the numbers with random variables and spread the columns and rows further apart. Note that we now specify this to be a `matrix of math nodes`, and specify separation of columns and rows. You may have to play with these margins, but I have found `2em` to be an appropriate size for most hierarchical diagrams.

Another point to make about the Ti*k*Z matrix is that empty "cells" are allowed. As you can see below, the top row doesn't have values in the first cell (*before* the first `&`) or the last cell (*after* the second `&`). This is convenient for when wish to denote one parameter as being a higher level of hierarchy than multiple "children" in the next level of hierarchy.

{% highlight TeX %}
\matrix[matrix of math nodes, column sep=2em, row sep=2em] (mat)
{
    & \mu, \tau^2 & \\
    \theta_1 & \ldots & \theta_n \\
    y_1 & \ldots & y_n \\
    & \sigma^2 & \\
};
{% endhighlight %}

![Just math](/assets/img/hierarchical-graph-2.svg)

Final (simple model)

{% highlight TeX %}
\matrix[matrix of math nodes, column sep=30 pt, row sep=30 pt] (mat)
{
    & \mu, \tau^2 & \\ 
    \theta_1 & \ldots & \theta_n \\
    y_{1,1}, \ldots, y_{n_1, 1} & \ldots & y_{1, J}, 
    \ldots, y_{n_J, J} \\
    & \sigma^2 & \\
};

\foreach \column in {1, 3}
{
    \draw[->,>=latex] (mat-1-2) -- (mat-2-\column);
    \draw[->,>=latex] (mat-2-\column) -- (mat-3-\column);
    \draw[<-,>=latex] (mat-3-\column) -- (mat-4-2);
}

\node[anchor=east] at ([xshift =-40pt]mat-2-1) 
{$\theta_j \sim \text{N}(\mu, \tau^2)$};
\node[anchor=east] at ([xshift =-40pt]mat-3-1) 
{$y_{i, j} \sim \text{N}(\theta_j, \sigma^2)$};
{% endhighlight %}

![Include arrows and names](/assets/img/hierarchical-graph.svg)

# References

{% bibliography --cited %}
