---
layout: post
title:  "Creating Hierarchical Model Diagrams with LaTeX"
date:   2016-02-26 15:27:47 -0500
comments: true
tags:
- LaTeX
- Hierarchical Models
---

Simple example with numbers
{% highlight TeX %}
\matrix[matrix of nodes] (mat)
{
    1 & 2 & 3 \\
    4 & 5 & 6 \\
    7 & 8 & 9 \\
};
{% endhighlight %}

![Just number](/assets/img/hierarchical-graph-1.svg)

Now use math symbols and separate rows and columns bit

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
