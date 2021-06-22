const youtubedl = require('youtube-dl-exec')
const fs = require('fs')
const args = process.argv.slice(2);


youtubedl.getInfo(`https://www.youtube.com/watch?v=${args[0]}`,       (err, info) => {
    if (err != null) {
      throw(err); // invoke the error callback in case of an error
    } else {
      console.log(info.url); // invoke the success callback with the reponse
    }
  })
