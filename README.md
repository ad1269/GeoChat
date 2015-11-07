# GeoChat

<h1>Code Layout</h1>
I’d like to explain how I laid out my code, just to make it a little bit easier for you guys to take a look at it. Inside my main directory, you should find two subfolders called Client and Server. Inside client are all the swift source files I’ve personally written for this project (meaning I haven’t included any of the code from external libraries I’m using). If you’d like to run the project, or take a look at some of the external libraries I used, you can look inside the GeoChat Full Client folder. This contains all dependencies and frameworks and is ready to be built (make sure to open the GeoChat.xcworkspace file). Likewise, in the Server folder, you can find all the php files that I wrote to communicate with the client. To look at the full server, including external libraries and directory structure, take a look inside the GeoChat Full Server folder.

<h1>Project Overview</h1>
GeoChat is a social network that works based on location. You can view all posts within a 10-mile radius of your current location. You can upvote or down vote these posts, and can view posts by their popularity or time posted. The search feature also allows you to search for a place, and view all posts within 10 miles of your chosen location. You can also take pictures or video and post them, along with a description or caption. The next few features I’m going to explain are not yet fully functional, but currently under construction. You can also search for users, and send them requests to be added as friends. The notifications tab displays important activity from your friends, or from any posts that you’ve followed.