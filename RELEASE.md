# How to release this project

* Use one release issue for all projects https://gitlab.com/oersi/oersi-setup/-/issues/new
* Create release tag
```
git tag -a <RELEASE-VERSION> -m "release <RELEASE-VERSION> (Ref <ISSUE-URL>)"
```
* Push
```
git push origin <RELEASE-VERSION>
```