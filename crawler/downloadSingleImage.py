from imgurpython import ImgurClient

#client_id = '140f860c98af613'
#client_secret = '96ab107bb54adec22e30bab0acf46f801180ec91'
client_id = '4f22e772b8ad776'
client_secret = '4075e61182cdc5e333417254a4d403ca58ec7b45'

client = ImgurClient(client_id, client_secret)

from pprint import pprint
items = client.gallery()
for item in items:
    print item.link 
    print item.title 
    break 