from imgurpython import ImgurClient
from pprint import pprint

#client_id = '140f860c98af613'
#client_secret = '96ab107bb54adec22e30bab0acf46f801180ec91'
client_id = '4f22e772b8ad776'
client_secret = '4075e61182cdc5e333417254a4d403ca58ec7b45'

client = ImgurClient(client_id, client_secret)

result=client.gallery_search("snowboarding", advanced=None, sort='time', window='all', page=0)
for items in result:
    print items.link
    print items.title 
