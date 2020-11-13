# How to release this project

* Create release issue https://gitlab.com/oersi/oersi-setup/issues/new
* Checkout the develop branch
```
git checkout develop
```
* Set release artifacts in _oersi-setup/ansible/group_vars/all.yml_ and commit
```
git add oersi-setup/ansible/group_vars/all.yml
git commit -m "use release artifacts (Ref <ISSUE-URL>)"
```
* Merge develop into master
```
git checkout master
git merge develop
```
* Create release tag
```
git tag -a <RELEASE-VERSION> -m "release <RELEASE-VERSION> (Ref <ISSUE-URL>)"
```
* Checkout the develop branch
```
git checkout develop
```
* Set develop artifacts in _oersi-setup/ansible/group_vars/all.yml_ and commit
```
git add oersi-setup/ansible/group_vars/all.yml
git commit -m "use snapshot artifacts (Ref <ISSUE-URL>)"
```
* Push
```
git push origin develop
git push origin master
git push origin <RELEASE-VERSION>
```