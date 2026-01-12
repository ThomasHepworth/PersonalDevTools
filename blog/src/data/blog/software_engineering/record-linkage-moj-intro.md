---
author: Tom Hepworth
pubDatetime: 2026-01-12T10:00:00Z
modDatetime: 2026-01-12T10:00:00Z
title: "Record linkage at the Ministry of Justice: why we built Splink"
slug: record-linkage-moj
postCategory: software_engineering
featured: true
draft: false
tags:
  - data-engineering
  - record-linkage
  - splink
  - probabilistic-linkage
description: Why record linkage matters at the Ministry of Justice, why deterministic methods fall short, and how those challenges led to Splink.
ogImage: "https://user-images.githubusercontent.com/7570107/85285114-3969ac00-b488-11ea-88ff-5fca1b34af1f.png"
---

<figure class="flex justify-center">
  <img
    src="https://user-images.githubusercontent.com/7570107/85285114-3969ac00-b488-11ea-88ff-5fca1b34af1f.png"
    alt="Splink logo"
    class="w-1/2 max-w-full h-auto"
  />
</figure>

# An overview of our record linkage strategy at the Ministry of Justice

This post sets out why record linkage matters at the Ministry of Justice (MoJ), why deterministic approaches often fall short in practice, and how that led to the creation of Splink.

## Why record linkage matters

In an ideal world, every person, case, and organisation would share a universal identifier. Linking across data sources would be trivial, and you could answer questions that are otherwise out of reach.

Reality is messier. Many organisations have fragmented data spread across multiple systems, with no reliable, universal identifier. Source systems are designed primarily for operations, not analytics. Identifiers that would make linkage easy can be missing, inconsistently recorded, or unavailable for legal and practical reasons. Data protection constraints can further limit what is captured or retained.

The MoJ is no different. Courts, prisons, and probation systems often lack a shared identifier and provide no straightforward way to traverse between them. Personal data can be incomplete, inconsistently recorded, and prone to change over time.

This matters because the absence of a reliable identifier constrains the services we can provide and the questions we can answer. Before the launch of Common Platform, for example, it was difficult to track timeliness end to end across the magistrates' and Crown Courts, limiting our ability to measure performance and understand where delays accumulated.

At our scales, record linkage is both a statistical and an engineering challenge. Some datasets run into the tens of millions of rows, and some linkage exercises involve hundreds of millions of records. A naive cartesian join (every record compared with every other) is infeasible. We need approaches that are accurate, transparent about uncertainty, and engineered to scale, including careful blocking strategies that reduce the search space to plausible candidate pairs.

That leads to a simple question: **what tools and methods let us link records reliably at MoJ scale, while being transparent about uncertainty and robust to messy real-world data?**

## Deterministic linkage: strengths and limits

Many linkage efforts start with deterministic linkage. In SQL terms, this is a join: if a set of fields match exactly, we treat the records as referring to the same entity. Users typically define combinations of identifiers they believe indicate a match and compile large join conditions, removing previously identified matches from future joins.

For example, you might decide that if two entries match on first name, last name, date of birth, and address, they should be labelled as the same individual. Deterministic linkage can work well when data quality is high and the join keys are reliable. It tends to produce high precision, it slots neatly into existing databases and pipelines, and it is computationally efficient.

But the brittleness shows as soon as data quality slips. Completeness issues, typographical errors, formatting inconsistencies, and changes over time can turn true matches into missed matches. In practice, deterministic methods often underperform on recall, and the shortfall is not evenly distributed across groups and contexts.

A concrete example at the MoJ is names. They may be recorded differently across systems, including variations in spelling, spacing, punctuation, ordering, and transliteration. Non-Anglicised names can be particularly vulnerable to inconsistent recording upstream, where phonetic approximations or unfamiliarity lead to persistent discrepancies. If you rely on exact matching, these issues can propagate into biased linkage outcomes, with some individuals systematically less likely to be linked across systems.[^1]

## Splink as a response

These challenges are a big part of what led to the creation of Splink. Splink is a scalable entity resolution and record linkage library written in Python. It provides an API for deduplicating datasets and linking between two or more datasets, while pushing heavy computation down into high-performance database engines.

Under the hood, Splink implements a probabilistic linkage model closely related to the Fellegi-Sunter framework.[^2][^3] This treats linkage as an evidence-based decision rather than an all-or-nothing rule. Instead of requiring exact agreement, you define a set of comparisons (for example, name similarity or date-of-birth agreement), and the model combines those signals to estimate how likely it is that two records refer to the same entity.

This matters because it is more robust to imperfect data and gives you a structured way to express uncertainty. Rather than forcing every pair into "match" or "no match", probabilistic linkage supports practical decision-making. In practice, that means separating very high-confidence links from borderline cases that may need review, and being explicit about where uncertainty remains.

Splink's statistical specification is similar in spirit to the R `fastLink` package, which is accompanied by an academic paper describing the model and its practical use at scale.[^4] Alongside that, the Splink documentation and a series of interactive articles explore the theory behind probabilistic linkage and how it relates to Splink.[^5]

Where Splink differs from many "model-only" implementations is in how it is engineered for real-world use. The library translates your linkage configuration into SQL that runs inside the chosen backend, keeping Python as the orchestration layer while relying on mature database engines for heavy computation. Internally, Splink uses abstract base classes to define the core contract of a "linker", making it straightforward to support multiple SQL backends while keeping the user-facing API consistent.

That design has allowed Splink to run on DuckDB, PySpark, Athena, SQLite, and Postgres. In practice, we operationalised this at the MoJ on PySpark initially, faced scaling challenges, and ultimately pivoted to DuckDB for much of our processing.

## Further reading

- Splink on GitHub: https://github.com/moj-analytical-services/splink
- Splink theory guide on record linkage: https://moj-analytical-services.github.io/splink/topic_guides/theory/record_linkage.html
- Splink theory guide on the Fellegi-Sunter model: https://moj-analytical-services.github.io/splink/topic_guides/theory/fellegi_sunter.html
- Splink theory guide on probabilistic vs deterministic linkage: https://moj-analytical-services.github.io/splink/topic_guides/theory/probabilistic_vs_deterministic.html
- Robin Linacre's interactive introduction to probabilistic linkage: https://www.robinlinacre.com/intro_to_probabilistic_linkage/
- Robin Linacre on the mathematics of the Fellegi-Sunter model: https://www.robinlinacre.com/maths_of_fellegi_sunter/
- Enamorado, Fifield, and Imai on probabilistic record linkage at scale, with fastLink: https://imai.fas.harvard.edu/research/files/linkage.pdf

[^1]: Splink blog post on bias in data linking, including naming inconsistencies and downstream impacts: https://moj-analytical-services.github.io/splink/blog/2024/08/19/bias-in-data-linking.html
[^2]: Robin Linacre's interactive introduction to probabilistic record linkage: https://www.robinlinacre.com/intro_to_probabilistic_linkage/
[^3]: Robin Linacre's explanation of the mathematics behind the Fellegi-Sunter model: https://www.robinlinacre.com/maths_of_fellegi_sunter/
[^4]: Enamorado, Fifield, and Imai, "A fast and accurate approach to record linkage and de-duplication": https://imai.fas.harvard.edu/research/files/linkage.pdf
[^5]: Splink documentation, including theory guides and interactive material on record linkage and the Fellegi-Sunter model: https://moj-analytical-services.github.io/splink/topic_guides/theory/record_linkage.html
