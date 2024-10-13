## 5. Second-System Effect

### Key Takeaways

- Be cautious of overconfidence and maintain discipline when building **any** system, especially the second system.

### Overview

Overconfidence and unrestrained ideas are among the most dangerous challenges in system design. While unbounded creativity can be a valuable asset, it also has the potential to lead a project astray. In my experience, I have witnessed numerous projects falter due to an inability to stay focused and on schedule. All too often, the allure of new ideas causes delays and confusion.

Similarly, overconfidence—though rare in an industry frequently plagued by imposter syndrome and the constant need for learning—can lead to poor decisions. Chapter 5 of Brooks' *The Mythical Man-Month* explores these two pitfalls within the context of building a second system.

One of the most common issues I have encountered is the tendency for developers to seek improvement constantly. While it's exciting to identify areas for enhancement during development, this same excitement can lead to feature creep, delaying the project and creating a stressful environment. Is a more feature-rich product the desired outcome? Often, yes, but upon reflection, we find that bloated, overcomplicated systems rarely bring the benefits we expect.

Brooks identifies this phenomenon as the "second-system effect"—the tendency for the second system to become over-engineered and burdened with unnecessary features due to inflated expectations and overconfidence.

> “The second is the most dangerous system a man ever designs... The general tendency is to over-design the second system, using all the ideas and frills that were cautiously sidetracked on the first one.”

Brooks stresses the importance of discipline when tackling the second system. Developers and architects must resist the temptation to introduce every new idea they had set aside during the development of the first system. Discipline and focus are critical in avoiding the pitfalls of the second-system effect.

### Avoiding the Trap

How can we prevent falling into the second-system trap?

Brooks' first suggestion is to only hire an architect who has already built more than one system. This is an idealistic notion that may not always be feasible due to factors like retirement and career changes. However, Brooks' true recommendation is the need for discipline. The architect, or the design lead, **must** exhibit restraint and caution, just as they did with the first system.

Realistically, it isn't always possible to hire someone with experience in multiple systems, but the core principle of discipline remains paramount. Brooks outlines two key approaches:

1. **Discipline**: The architect must rein in their excitement. The caution and restraint applied to the first system need to be repeated when building the second. The temptation to over-engineer must be resisted at all costs.
2. **Structured Management**: Management must enforce a disciplined approach. The architect and the team should avoid trying to add every enhancement or improvement that comes to mind.

Having worked primarily in smaller teams, where "architects" are also responsible for implementation details, I've observed how easily embellishments and personal flair creep into projects. These situations provide fertile ground for feature creep, which can be detrimental to the project's success. In such environments, discipline is essential, as is having colleagues who are unafraid to challenge decisions constructively. Without this balance, it's easy to stray from the project's core goals.

Proper planning and a disciplined technical lead can help to manage the persistent desire to refine, refactor, and innovate. By maintaining focus, teams can avoid the dangers of the second-system effect and deliver functional, elegant systems on time.

#### Useful Links

* [hgraca's blog post](https://herbertograca.com/2018/09/14/5-the-second-system-effect/)
* [tcagley blog](https://tcagley.wordpress.com/2015/08/01/re-read-saturday-the-mythical-man-month-part-5-the-second-system-effect/)
