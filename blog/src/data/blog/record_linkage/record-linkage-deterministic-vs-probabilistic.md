---
author: Tom Hepworth
pubDatetime: 2026-01-12T10:00:00Z
modDatetime: 2026-01-12T10:00:00Z
title: "Deterministic vs probabilistic record linkage: why Splink exists"
slug: deterministic-vs-probabilistic-linkage
postCategory: 🔗 record linkage
featured: true
draft: false
unlist: true
tags:
  - data-engineering
  - record-linkage
  - splink
  - probabilistic-linkage
description: Why deterministic linkage falls short in practice, how probabilistic methods address those limitations, and how those challenges led to Splink.
ogImage: "https://user-images.githubusercontent.com/7570107/85285114-3969ac00-b488-11ea-88ff-5fca1b34af1f.png"
---

<figure class="flex justify-center">
  <img
    src="https://user-images.githubusercontent.com/7570107/85285114-3969ac00-b488-11ea-88ff-5fca1b34af1f.png"
    alt="Splink logo"
    class="w-1/2 max-w-full h-auto"
  />
</figure>

# Deterministic vs probabilistic record linkage

This post introduces record linkage, explains why deterministic approaches often fall short in practice, and how those challenges led to the creation of Splink.

## Why record linkage matters

In an ideal world, every person, case, and organisation would share a universal identifier. Linking across data sources would be trivial, and you could answer questions that are otherwise out of reach.

Reality is messier. Most organisations have fragmented data spread across multiple systems, with no reliable, universal identifier. Source systems are designed primarily for operations, not analytics. Identifiers that would make linkage easy can be missing, inconsistently recorded, or unavailable for legal and practical reasons. Data protection constraints can further limit what is captured or retained.

This pattern is common across government, healthcare, finance, and research. Different systems capture overlapping populations but lack a shared key. Personal data can be incomplete, inconsistently recorded, and prone to change over time.

The absence of a reliable identifier constrains the services organisations can provide and the questions they can answer. Without linkage, you cannot track individuals across touchpoints, measure end-to-end journeys, or build a complete picture from fragmented sources.

At scale, record linkage is both a statistical and an engineering challenge. Some datasets run into the tens of millions of rows, and some linkage exercises involve hundreds of millions of records. A naive cartesian join (every record compared with every other) is infeasible. We need approaches that are accurate, transparent about uncertainty, and engineered to scale, including careful blocking strategies that reduce the search space to plausible candidate pairs.

That leads to a simple question: **what tools and methods let us link records reliably at scale, while being transparent about uncertainty and robust to messy real-world data?**

## Deterministic linkage: strengths and limits

Many linkage efforts start with deterministic linkage. In SQL terms, this is a join: if a set of fields match exactly, we treat the records as referring to the same entity. Users typically define combinations of identifiers they believe indicate a match and compile large join conditions, removing previously identified matches from future joins.

For example, you might decide that if two entries match on first name, last name, date of birth, and address, they should be labelled as the same individual. Deterministic linkage can work well when data quality is high and the join keys are reliable. It produces a high precision output, slotting neatly into existing databases and pipelines, and it is computationally efficient (typically a collection of hash-joins in modern database engines).

But the brittleness shows as soon as data quality slips. Completeness issues, typographical errors, formatting inconsistencies, and changes over time can turn true matches into missed matches. In practice, deterministic methods often underperform on recall, and the shortfall is not evenly distributed across groups and contexts.

A concrete example is names. They may be recorded differently across systems, including variations in spelling, spacing, punctuation, ordering, and transliteration. Non-Anglicised names can be particularly vulnerable to inconsistent recording, where phonetic approximations or unfamiliarity lead to persistent discrepancies. If you rely on exact matching, these issues can propagate into biased linkage outcomes, with some individuals systematically less likely to be linked across systems.[^1]

## Probabilistic linkage: a different approach

Probabilistic linkage treats the problem differently. Instead of requiring exact agreement on a set of fields, it treats linkage as an evidence-based decision. You define a set of comparisons (for example, name similarity or date-of-birth agreement), and a model combines those signals to estimate how likely it is that two records refer to the same entity.

To see the difference, consider two records that clearly refer to the same person but contain minor discrepancies:

<figure style="max-width: 750px; margin: 1.5rem auto;">
  <img src="/assets/record-linkage/deterministic-failure-example.svg" alt="Deterministic linkage fails on records with typos and missing values" style="width: 100%; border-radius: 8px;" />
  <figcaption style="text-align: center; font-style: italic; margin-top: 0.5rem;">Deterministic linkage: a single typo in surname or a transposed digit in date of birth causes the entire match to fail.</figcaption>
</figure>

In this instance, even if you used a collection of deterministic rules (for example, searching for a match on name and date of birth, or name and address), you would still miss the match due to the discrepancies.

Probabilistic linkage, by contrast, weighs the evidence from each field. A model trained on your data learns how much evidence each type of agreement (or disagreement) provides. The waterfall chart below shows this in action—the same record pair, but now each comparison contributes to an overall match score:

<figure style="max-width: 800px; margin: 1.5rem auto;">
  <div id="splink-waterfall-chart" style="width: 100%;"></div>
  <figcaption style="text-align: center; font-style: italic; margin-top: 0.5rem;">Probabilistic linkage: each comparison adds or subtracts evidence. Despite imperfect data, the cumulative weight produces a 99% match probability.</figcaption>
</figure>

<script type="module">
  import embed from 'https://cdn.jsdelivr.net/npm/vega-embed@6/+esm';
  const spec = await fetch('/assets/record-linkage/waterfall-chart-spec.json').then(r => r.json());
  embed('#splink-waterfall-chart', spec, {actions: false, renderer: 'svg'});
</script>

This matters because it is more robust to imperfect data and gives you a structured way to express uncertainty. Rather than forcing every pair into "match" or "no match", probabilistic linkage supports practical decision-making. You can separate very high-confidence links from borderline cases that may need review, and be explicit about where uncertainty remains.

The statistical foundations come from the Fellegi-Sunter framework, developed in the 1960s.[^2][^3] The core idea is that each comparison (name, date of birth, address, etc.) provides evidence for or against a match. Fields that agree on rare values provide stronger evidence than fields that agree on common values. The model combines these signals into an overall match weight or probability.

## Splink as a response

These challenges, the brittleness of deterministic linkage and the need for scalable probabilistic methods, are what led to the creation of Splink. Splink is a scalable entity resolution and record linkage library written in Python. It provides an API for deduplicating datasets and linking between two or more datasets, while pushing heavy computation down into high-performance database engines such as DuckDB, Spark and AWS Athena.

Under the hood, Splink implements a probabilistic linkage model closely related to the Fellegi-Sunter framework.[^2][^3] Rather than forcing every pair into "match" or "no match", it estimates how likely it is that two records refer to the same entity based on the evidence from each comparison.

Splink's statistical specification is similar in spirit to the R `fastLink` package, which is accompanied by an academic paper describing the model and its practical use at scale.[^4] The Splink documentation and a series of interactive articles explore the theory behind probabilistic linkage and how it relates to Splink.[^5]

Where Splink differs from many "model-only" implementations is in how it is engineered for real-world use. The library translates your linkage configuration into SQL that runs inside the chosen backend, keeping Python as the orchestration layer while relying on mature database engines for heavy computation. Internally, Splink uses abstract base classes to define the core contract of a "linker", making it straightforward to support multiple SQL backends while keeping the user-facing API consistent.

That design has allowed Splink to run on DuckDB, PySpark, Athena, SQLite, and Postgres. In practice, this flexibility lets teams slot linkage into their existing data platform rather than building infrastructure around it.

## References

[^1]: Splink blog post on bias in data linking, including naming inconsistencies and downstream impacts: https://moj-analytical-services.github.io/splink/blog/2024/08/19/bias-in-data-linking.html
[^2]: Robin Linacre's interactive introduction to probabilistic record linkage: https://www.robinlinacre.com/intro_to_probabilistic_linkage/
[^3]: Robin Linacre's explanation of the mathematics behind the Fellegi-Sunter model: https://www.robinlinacre.com/maths_of_fellegi_sunter/
[^4]: Enamorado, Fifield, and Imai, "A fast and accurate approach to record linkage and de-duplication": https://imai.fas.harvard.edu/research/files/linkage.pdf
[^5]: Splink documentation, including theory guides and interactive material on record linkage and the Fellegi-Sunter model: https://moj-analytical-services.github.io/splink/topic_guides/theory/record_linkage.html

---

## Further reading

If you want to go deeper on record linkage and Splink:

**Splink documentation**
- [Splink on GitHub](https://github.com/moj-analytical-services/splink)
- [Theory guide: Record linkage](https://moj-analytical-services.github.io/splink/topic_guides/theory/record_linkage.html)
- [Theory guide: Fellegi-Sunter model](https://moj-analytical-services.github.io/splink/topic_guides/theory/fellegi_sunter.html)
- [Theory guide: Probabilistic vs deterministic linkage](https://moj-analytical-services.github.io/splink/topic_guides/theory/probabilistic_vs_deterministic.html)

**Interactive articles by Robin Linacre**
- [Introduction to probabilistic linkage](https://www.robinlinacre.com/intro_to_probabilistic_linkage/)
- [The mathematics of Fellegi-Sunter](https://www.robinlinacre.com/maths_of_fellegi_sunter/)

**Academic papers**
- [Enamorado, Fifield, and Imai - "A fast and accurate approach to record linkage and de-duplication"](https://imai.fas.harvard.edu/research/files/linkage.pdf)

---

## References

[^1]: Splink blog post on bias in data linking: https://moj-analytical-services.github.io/splink/blog/2024/08/19/bias-in-data-linking.html
[^2]: Robin Linacre, Introduction to probabilistic record linkage: https://www.robinlinacre.com/intro_to_probabilistic_linkage/
[^3]: Robin Linacre, Mathematics of Fellegi-Sunter: https://www.robinlinacre.com/maths_of_fellegi_sunter/
[^4]: Enamorado, Fifield, and Imai, "A fast and accurate approach to record linkage and de-duplication": https://imai.fas.harvard.edu/research/files/linkage.pdf
[^5]: Splink documentation: https://moj-analytical-services.github.io/splink/topic_guides/theory/record_linkage.html