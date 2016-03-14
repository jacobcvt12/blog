---
layout: post
title:  "Creating Hierarchical Model Diagrams with LaTeX"
date:   2016-02-26 15:27:47 -0500
comments: true
tags:
- LaTeX
- Hierarchical Models
---

Bayesian models are often considered in a hierarchical fashion. Even when there is no multilevel structure to the data, the model can still be implicitly hierarchical due to the relationship of hyperparameters, parameters of interest, and data. However, the complicated structure of hierarchical models can be difficult to communicate to an audience. Here I show how to present these models using *diagrams*.

For a simple hierarchical Bayesian model, the structure can be written as a series of likelihoods, random variables, and the distributions which they follow. For example, the number of cases of pancreatic cancer may have been collected by county (with hypothetically standardized population sizes). A simple model for learning about this data could use a Poisson likelihood and a Gamma prior on the mean cancer cases with parameters *a* and *b*.

$$\begin{align}
y_i & \sim \text{Poisson}(\theta) \\
\theta & \sim \text{Gamma}(a, b)
\end{align}$$

While the above presentation of this simple model is concise and easy to understand, models with multiple levels of hierarchy can become unwieldy to describe in such a manner. Instead, the relationships between data and parameters is clearer and more interpretable through a diagram. 

![Just number](/assets/img/hierarchical-comparison.svg)

I have created this diagram with the \\(\LaTeX\\) library Ti*k*Z {% cite tantau2013 %}. While there are several packages within Ti*k*Z for creating graphics, however I have found `matrix` to be the most concise and easiest to learn.

# Ti*k*Z and diagrams for hierarchical models

The necessary preamble and code for creating a Ti*k*Z graphic is

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

To first begin building a diagram, note that a Ti*k*Z matrix should be thought of in terms of a linear algebra matrix. This matrix diagram is specified using `\matrix` followed by options of the matrix and the name of the matrix (here chosen to be `mat`). Cells on the same row are separated by `&`'s, and new rows are begun by `\\`. If one row has more columns than the others (more `&`'s), the other rows will have columns implicitly added to maintain a rectangular shape.

{% highlight TeX %}
\matrix[matrix of nodes] (mat)
{
    1 & 2 & 3 \\
    4 & 5 & 6 \\
    7 & 8 & 9 \\
};
{% endhighlight %}

![Just number](/assets/img/hierarchical-graph-1.svg)

For this matrix to look anything like a hierarchical diagram, we first need to replace the numbers with random variables and specify an option to spread the columns and rows further apart. To use `math mode` for the nodes, we now specify the matrix to be a `matrix of math nodes`, and pass an option for separation of columns and rows. You may have to play with these margins, but I have found `20pt` to be an appropriate size for most hierarchical diagrams.

Another point to make about the Ti*k*Z matrix is that empty "cells" are allowed. As you can see below, the top row doesn't have values in the first cell (*before* the first `&`) or the last cell (*after* the second `&`). This is convenient for when wish to denote one parameter as being a higher level of hierarchy with multiple "children" in the next level of hierarchy.

{% highlight TeX %}
\matrix[matrix of math nodes, column sep=20pt, row sep=20pt] (mat)
{
    & \mu, \tau^2 & \\
    \theta_1 & \ldots & \theta_n \\
    y_1 & \ldots & y_n \\
    & \sigma^2 & \\
};
{% endhighlight %}

![Just math](/assets/img/hierarchical-graph-2.svg)

Finally, to make the diagram worthwhile, Ti*k*Z `matrix`'s allow for directional arrows between the nodes and - if need be - text to the side describing a layer of the hierarchy. For this step, it is important to understand the naming of nodes. Within the matrix, each node takes a name based on the name of matrix as well as the location of the cell. This name is constructed as `named-of-matrix_row-number_col-number`. Thus, in our example above, \\(\sigma^2\\) could be referenced by `mat-4-2`.

To add these lines and descriptions, we first construct the matrix as before. Following the construction, we draw the lines. The `\draw` command draws a line from one node to the next. The first option (here `->` and `<-`) specifies the direction of the arrow. I have placed the (shared) variance below the observations (\\(y_i\\)) and reversed the direction of the arrows to indicated hierarchy level. The section option (not required) specifies the type of arrowhead. Below I choose to use the `latex` style. To avoid writing more code, I use a `\foreach` loop to draw similar lines for columns 1 and 3.

Next, the text descriptions are created via manually specified nodes. These nodes are "anchored" to already placed nodes in the diagram and placed relative to the specified nodes. The nodes are created by specifying the direction of the anchor and distance from the anchor. Here I have chosen `-40pt` as my distance. Unfortunately, this number depends on the length of the description, and I have not found a better way for determining it other than through trial-and-error.

{% highlight TeX %}
\matrix[matrix of math nodes, column sep=2em, row sep=2em] (mat)
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

![Include arrows and names](/assets/img/hierarchical-graph-3.svg)

# A few tweaks

If some parameters need to be farther from others, you can adjust one column separation manually via an option to the `&`. Furthermore, you may want to highlight important parameters with a color.

{% highlight TeX %}
\matrix[matrix of math nodes, column sep=2em, row sep=2em] (mat)
{
    & \mu, \tau^2 & &[4em] \beta \\ 
    \theta_1 & \ldots & \theta_n & \alpha \\
    y_{1,1}, \ldots, y_{n_1, 1} & \ldots & y_{1, J}, 
    \ldots, y_{n_J, J} \\
    & |[blue]| \sigma^2 & \\
};

\foreach \column in {1, 3}
{
    \draw[->,>=latex] (mat-1-2) -- (mat-2-\column);
    \draw[->,>=latex] (mat-2-\column) -- (mat-3-\column);
    \draw[<-,>=latex] (mat-3-\column) -- (mat-4-2);
}

\draw[->,>=latex] (mat-1-4) -- (mat-2-4);
\draw[->,>=latex] (mat-2-4) -- (mat-3-3);

\node[anchor=east] at ([xshift =-40pt]mat-2-1) 
{$\theta_j \sim \text{N}(\mu, \tau^2)$};
\node[anchor=east] at ([xshift =-40pt]mat-3-1) 
{$y_{i, j} \sim \text{N}(\theta_j + \alpha, \sigma^2)$};
{% endhighlight %}

![Different Spacing](/assets/img/hierarchical-graph-4.svg)

# Some pitfalls

Using the `matrix` library limits one to a model that has nodes structured in a martrix formart. For example, if there are four paramaters at one level , but three on another, you are stuck either having a ragged level, or have to structure your matrix to have 12 columns, with many empty nodes. For a situation like this, you may be better off using a different Ti*k*Z package.

Additionally, the learning curve of creating hierarchical diagrams with \\(\LaTeX\\) is certainly higher than using a software like Adobe Illustrator. Besides the obvious benefit of \\(\LaTeX\\) being free and open source, when combined with something like `knitr` {% cite xie2015 %}, the diagrams can be created and modified in the same document that the other figures and analysis are in.

# References

{% bibliography --cited %}
