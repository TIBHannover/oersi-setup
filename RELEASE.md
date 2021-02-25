# How to release this project

* Use one release issue for all projects https://gitlab.com/oersi/oersi-setup/-/issues/new
* Set release artifacts in _ansible/group_vars/all.yml_ and commit
```
git add ansible/group_vars/all.yml
git commit -m "use release artifacts (Ref <ISSUE-URL>)"
```
* Create release tag
```
git tag -a <RELEASE-VERSION> -m "release <RELEASE-VERSION> (Ref <ISSUE-URL>)"
```
* Set branch artifacts in _ansible/group_vars/all.yml_ and commit
```
git add ansible/group_vars/all.yml
git commit -m "use branch artifacts (Ref <ISSUE-URL>)"
```
* Push
```
git push origin master
git push origin <RELEASE-VERSION>
```
