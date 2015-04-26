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

for items in result:
    print "Downloading " + items.link + " ....."
   
    extension = items.type
    extension = extension.replace('image/', '')
    imgName = searchTag + str(currDownload)
    extension = "." + extension
    commCount = 0
    folder = "" 

    if extension == ".gif":
        folder = "crawledGIFImages"
    else:
        folder = "crawledImages"

    #Writing title as first caption
    
    if extension == ".gif":
        capgif.write(imgName + extension + "#" + str(commCount) + "\t" + items.title + "\n")
    else:
        cap.write(imgName + extension + "#" + str(commCount) + "\t" + items.title + "\n")

    comments = client.gallery_item_comments(items.id, sort='best')

    for comment in comments:
        if commCount == 4:
            break
        #Writing top 4 captions apart from title
        if extension == ".gif":
            capgif.write(imgName + extension + "#" + str(commCount) + "\t" + comment.comment + "\n")
        else:
            cap.write(imgName + extension + "#" + str(commCount) + "\t" + comment.comment + "\n")
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
cap.close()
capgif.close()


