options.info = True

-- set up an app password, your main password isn't allowed here
pwd = get_password('Password: ')

fm = IMAP {
 server = 'imap.fastmail.com',
 port = 993,
 ssl = 'tls1.2',
 username = 'funollet@fastmail.fm',
 password = pwd,
}

fm['lists/generic']:is_older(15):delete_messages()
fm['lists/lug']:is_older(15):delete_messages()
fm['lists/python']:is_older(15):delete_messages()
fm['lists/uec']:is_older(15):delete_messages()

fm['Sent Items']:is_older(60):delete_messages()
fm['Trash']:is_older(60):delete_messages()
