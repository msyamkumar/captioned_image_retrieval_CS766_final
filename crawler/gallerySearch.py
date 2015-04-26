from imgurpython import ImgurClient
import pprint
import sys
import os
import requests

searchTag = sys.argv[1]
downloadLimit = 100
currDownload = 0

#client_id = '140f860c98af613'
#client_secret = '96ab107bb54adec22e30bab0acf46f801180ec91'
client_id = '4f22e772b8ad776'
client_secret = '4075e61182cdc5e333417254a4d403ca58ec7b45'

client = ImgurClient(client_id, client_secret)

result=client.gallery_search(searchTag, advanced=None, sort='time', window='all', page=0)

#Create a directory to download the images to
cmd = "mkdir " + searchTag
os.system(cmd)

for items in result:
    print "Downloading " + items.link + " ....."
    print items.title
    '''
    for attr in dir(items):
        if hasattr( items, attr ):
                   print( "obj.%s = %s" % (attr, getattr(items, attr)))

    ''' 
    if currDownload < downloadLimit:
        #Download the image data
        response = requests.get(items.link)
        path = r'./{fldr}/{name}{ext}'.format(fldr=searchTag,
                                              name=currDownload,
                                              ext='.png')  

        fp = open(path, 'wb')
        fp.write(response.content)
        fp.close()
        currDownload += 1 
