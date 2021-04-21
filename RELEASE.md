# How to release all oersi components automatically

There is a linux shell script that can be used to automatically release all the oersi components: [tools/release/release.sh](tools/release/release.sh).
This includes commits to the version (release version, snapshot version), the release tag, setting the release-artifact-urls and the release-entry in gitlab.
You need to assure that you meet the requirements of the script.
Before the script can be executed, the first block of variables must be adjusted to the current release.

# How to release this project manually

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
