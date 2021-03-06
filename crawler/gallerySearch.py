from imgurpython import ImgurClient
import pprint
import sys
import os
import requests

#To remove non-ASCII characters
def remove_non_ascii_1(text):
    return ''.join([i if ord(i) < 128 else ' ' for i in text])

downloadLimit = 100

searchTags = ['chow', ' chow chow', 'keeshond', 'Brabancogriffon', 'Pembroke', ' Pembroke Welsh corgi', 'Cardigan', ' CardigaWelsh corgi', 'toy poodle', 'miniature poodle', 'standard poodle', 'Mexicahairless']

#client_id = '140f860c98af613'
#client_secret = '96ab107bb54adec22e30bab0acf46f801180ec91'
client_id = '4f22e772b8ad776'
client_secret = '4075e61182cdc5e333417254a4d403ca58ec7b45'
cap = open("crawledCaptions.txt", "w+")
capgif = open("crawledGIFCaptions.txt", "w+")
#Create a directory to download the images to
cmd = "rm -rf crawledImages" 
os.system(cmd)
cmd = "mkdir crawledImages" 
os.system(cmd)
cmd = "rm -rf crawledGIFImages" 
os.system(cmd)
cmd = "mkdir crawledGIFImages" 
os.system(cmd)

client = ImgurClient(client_id, client_secret)

for searchTag in searchTags:

    currDownload = 0

    result=client.gallery_search(searchTag, advanced=None, sort='time', window='all', page=0)

    for items in result:
        print "Downloading " + items.link + " ....."
  
        if not hasattr(items, "type"):
            continue

        extension = items.type
        extension = extension.replace('image/', '')
        imgName = searchTag + str(currDownload)
        imgName = imgName.replace(' ', '_')
        extension = "." + extension
        commCount = 0
        folder = "" 

        if extension == ".gif":
            folder = "crawledGIFImages"
        else:
            folder = "crawledImages"

    #Writing title as first caption
   
        captionData = imgName + extension + "#" + str(commCount) + "\t" + items.title + "\n"
        captionData = remove_non_ascii_1(captionData)

        if extension == ".gif":
            #capgif.write(captionData)
            continue
        else:
            cap.write(captionData)

        commCount += 1
        comments = client.gallery_item_comments(items.id, sort='best')

        for comment in comments:
            if commCount == 4:
                break
        #Writing top 4 captions apart from title

            captionData = imgName + extension + "#" + str(commCount) + "\t" + comment.comment + "\n"
            captionData = remove_non_ascii_1(captionData)
            print captionData
            if extension == ".gif":
                #capgif.write(captionData)
                continue
            else:
                cap.write(captionData)
            commCount += 1

        '''
        for attr in dir(comments):
            if hasattr( comments, attr ):
                       print( "obj.%s = %s" % (attr, getattr(comments, attr)))
        ''' 

        if currDownload < downloadLimit:
        #Download the image data
            response = requests.get(items.link)
            path = r'./{fldr}/{name}{ext}'.format(fldr=folder,
                                                  name=imgName,
                                                  ext=extension)  

            fp = open(path, 'wb')
            fp.write(response.content)
            fp.close()
            currDownload += 1 
        else:
            break
cap.close()
capgif.close()

