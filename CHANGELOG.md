# CHANGELOG

This file is used to list changes made in releasecreator.

## 1.2.0 - *2020-10-25*

- Fixed an issue where the parser would take any `##` combination
  - it will now look for a new line before it
  - It must end with a version number of d+.d+.d+
- If there is no other entries it will now match on end of file.

## 1.1.0 - *2020-10-25*

- Validate the HMAC signature

## 1.0.1 - *2020-10-24*

- Fix documentation to specify use of github token

## 1.0.0

- Initial creation
- Read the changelog between `## 1.0.1 - *2020-10-24*` and next `## header` for release body
- Update changelog with version number and date
- Create Release in github
- Add comment to merged PR with release version number
