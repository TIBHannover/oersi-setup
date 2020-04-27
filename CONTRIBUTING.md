# Contributing

If you contribute to the OER search index repositories, please ensure that you comply with the license, coding conventions, definition of done and the workflow for submitting merge requests.

## Workflow for external contributers

* If you'd like to contribute, start by searching through the issues and merge requests to see whether someone else has raised a similar idea or question.
* If you don't see your idea listed, do one of the following:
     * If your contribution is minor, such as a typo fix, open a merge request.
     * Otherwise open an issue first. That way, other people can weigh in on the discussion before you do any work.
* Fork the project into your personal namespace (or group).
* Create a feature branch in your fork from develop (don't work off develop or master).
* Write tests, code and documentations that satisfy [coding conventions](#coding-conventions).
* When the feature is fully implemented (see [Definition of Done](#definition-of-done)), submit a merge request to the develop branch in the original project.

## Coding conventions

* Code Style: [Google Code Style](https://google.github.io/styleguide/)
* No issues in [sonarlint](https://www.sonarlint.org/).
* [sonarcloud](https://sonarcloud.io/) Quality Gate passed for the merge request.
* Automated tests for new code should always be added.
* Language: everything (source code, comments, documentation, ...) in English.
* Commit messages guidelines
     * The commit subject must not contain more than 72 characters.
     * The commit subject and body must be separated by a blank line.
     * The issue or merge request should be added to the commit message.
     * Use issues and merge requests' full URLs instead of short references.

## Definition of Done

When can a task be marked as "finished"?

* All requirements of the feature implemented / all acceptance criteria fulfilled.
* Documentation is completely finished and understandable.
* Automated tests (e.g. unit tests) have been created, code coverage > 80%
* No open bugs (testing with [sonarlint](https://www.sonarlint.org/) / [sonarcloud](https://sonarcloud.io/))
* The code is finished and merged into the development branch.
* Concluding short comment in the issue: what has been done / what is the current status?

## Branching Strategy

### Internal Branching Workflow (gitflow)

* master
     * long living
     * stable branch
     * contains only release versions
* develop
     * long living
     * stable development branch
     * merge into master when ready for release
* feature- / topic-branches
     * branch from develop
     * merge into develop when ready / fully implemented (see [Definition of Done](#definition-of-done))
* hotfix
     * branch from master
     * for urgent fix in released version
     * merge into master and develop when ready
     
![Branching Strategy](doc/images/branching_strategy.png)

### Branching Workflow for external contributors (fork)

Any developer interested in collaborating should fork the repository and work on that local copy on a specific feature/topic. A feature branch should be created in the fork from the develop branch. When the feature is fully implemented (see [Definition of Done](#definition-of-done)), a merge request can be opened to merge the changes from the feature branch into the develop branch of the original repository.
