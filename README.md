# HipChat-to-Slack Migration Tools

These are some simple scripts to operate on a HipChat export archive. 


## Prerequisites
You need a HipChat export archive generated in HipChat, and its URL. These scripts will download the archive for you, so just copy the URL from the HipChat admin page. 

You also need a Google Spreadsheet (see the specification below). You could also use a CSV file, but the Google Spreadsheet allows people to collaborate more easily without passing CSV files around, and you can take advantage of enforced values, etc. 

You need to be able to authenticate with Google to access the spreadsheet. These scripts use the [`google_drive` gem](https://github.com/gimite/google-drive-ruby). For information on how to set up authentication using a service account, [read the docs](https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#on-behalf-of-no-existing-users-service-account) and modify the `google_key.json` file accordingly. 


You also need to make a directory for your archive and edit the `slack_config.json`file: 

* `hipchat_archive_url`: The link to your HipChat archive
* `hipchat_archive_location`: The path to your HipChat archive (no trailing slash)
* `hipchat_archive_name`: e.g. `hipchat-28367-2018-12-19_13-49-30.tar.gz.aes`
* `tarball_name`:  e.g. `hipchat-28367-2018-12-19_13-49-30.tar.gz`
* `google_spreadsheet_id`: the i.d. of your Google spreadsheet

Once you've configured all that, you should be able to:

1. `rake setup:download_archive` to download your archive
2. `rake setup:unpack` to decrypt the archive from the command line
3. `rake run` to operate on the files using the spreadsheet. 

Use `rake -T` to see all the rake tasks. If you want to run them individually:

1. `rake setup:download_archive` to download your archive
2. `rake setup:unpack` to decrypt the archive from the command line
3. `rake room_setup` to read the spreadsheet and fix rooms.json
4. `rake user_setup` to fix users.json.
5. `rake room_delete` to remove unneeded history directories.


# Spreadsheet Specification

A Google spreadsheet contains the migration information.  A few column positions are mandatory (bold)

| Column  | Contents | Notes  |
| ------------- | ------------- | ------------- |
| A  | Organization  | arbitrary, business unit   |
| B  | Stakeholder  | arbitrary, person responsible for coordinating  |
| C  | HipChat room owner  | arbitrary, desired owner  |
| D  | **HipChat room name**  | Mandatory  |
| E  | **HipChat room id**  | Mandatory. Replace with "-" if it's a new room |
| F  | Privacy  | "public" , "private" per HipChat export convention  |
| G  | **History migration**  | Mandatory. "no", "html_transcript", "slack_import", "slack_import_extended"|
| H  | Approved By  | Arbitrary, approving director's name for data migration  |
| I | **Slack Channel**  | Mandatory, Slack-legal name  |
| J  | Length  | Calculated, character length of Slack channel name   |
| K  | Slack Channel ID  | Not used for import preparation  |
| L | Notes | Arbitrary

# TODO

* Specification for the spreadsheet
* Automating a repack of the archive when you're done
* <s>Automating decrypt of the download</s>