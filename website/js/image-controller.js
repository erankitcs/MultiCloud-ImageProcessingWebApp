var imageController = {
    data: {
        config: null
    },
    uiElements: {
        imageCardTemplate: null,
        imageList: null,
        loadingIndicator: null
    },
    init: function (config,firebaseConfig) {
        this.uiElements.imageCardTemplate = $('#image-template');
        this.uiElements.imageList = $('#image-list');
        //this.uiElements.loadingIndicator = $('#loading-indicator');
        this.data.config = config;
        this.connectToFirebase(config.firebaseConfig);
    },

    connectToFirebase: function (firebaseConfig) {
        var that = this;
        console.log(firebaseConfig);
        firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();
        console.log("API details:");
        console.log(firebaseConfig);
        //console.log("Calling Add document")
        //addDocument(db);
        console.log("Reading document")
        getDocument(db,that);
        console.log("DOne.")
        
    },

    addImageOnScreen: function(id,data) {
        //console.log("id - ",id)
        //console.log("data-",data)
        var newImageElement = this.uiElements.imageCardTemplate.clone().attr('id', id);
        newImageElement.find('img').attr('src',data.url);
        if (data.captions[0]) {
          newImageElement.find('#caption').text(data.captions[0].text);
        }
        //newImageElement.find('#tags').append(data.tags.slice(0,5));
        $.each( data.tags, function( key, value ) {
          newImageElement.find('#tags').append("<span class=badge>"+value+"</span>");
        });
        $.each( data.categories.reverse(), function( key, value ) {
          newImageElement.find('#categories').append(value.name,' with score-',value.score,'<br>');
        });
        newImageElement.find('#backgroundcolor').css('color', data.dominantColorBackground).text('Background : '+data.dominantColorBackground);
        newImageElement.find('#foregroundcolor').css('color', data.dominantColorForeground).text('Foreground : '+data.dominantColorForeground);
        this.uiElements.imageList.prepend(newImageElement);
    },
    getElementForImage: function (imageID) {
      return $('#' + imageID);
  },
}

/* async function addDocument(db) {
    const docRef = db.collection('image_lense').doc('1234');
        const response_write = await docRef.set({
            imageName: 'Ada',
            prop: 'Lovelace',
            created: 1815
          });
}; */

async function getDocument(db,that){
    const snapshot = await db.collection('image_lense').onSnapshot(querySnapshot => {
        querySnapshot.docChanges().forEach(change => {
          if (change.type === 'added') {
            //console.log('New city: ', change.doc.data());
            //console.log('Key: ', change.doc.id);
            that.addImageOnScreen(change.doc.id,change.doc.data());

          }
          if (change.type === 'modified') {
            //console.log('Modified city: ', change.doc.data());
            //that.updateImageOnScreen();
            console.log("No Action Needed as It will be always new item into Firestore.")
          }
          if (change.type === 'removed') {
            //console.log('Removed city: ', change.doc.data());
            that.getElementForImage(change.doc.id).remove();
          }
        }) });
          
};