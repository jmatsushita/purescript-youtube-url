const youtubedl = require("youtube-dl");

exports._getUrl = (url) => (format) => {
  return function (onError, onSuccess) {
    // and callbacks
    const req = youtubedl.getInfo(
      `https://www.youtube.com/watch?v=${url}`,
      [`--format=${format}`],
      (err, info) => {
        if (err != null) {
          onError(err); // invoke the error callback in case of an error
        } else {
          onSuccess(info.url); // invoke the success callback with the reponse
        }
      }
    );

    // Return a canceler, which is just another Aff effect.
    return function (cancelError, cancelerError, cancelerSuccess) {
      // req.cancel(); // cancel the request
      // cancelerSuccess(); // invoke the success callback for the canceler
      cancelerError("Can't cancel this request.");
    };
  };
  Youtube.getInfo();
};
