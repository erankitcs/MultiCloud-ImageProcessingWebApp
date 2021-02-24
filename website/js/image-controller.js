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
        //this.uiElements.imageCardTemplate = $('#image-template');
        //this.uiElements.imageList = $('#image-list');
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
        console.log("Calling Add document")
        addDocument(db);
        console.log("Reading document")
        getDocument(db);
        console.log("DOne.")
        
    }
}

async function addDocument(db) {
    const docRef = db.collection('image_lense').doc('1234');
        const response_write = await docRef.set({
            imageName: 'Ada',
            prop: 'Lovelace',
            created: 1815
          });
};

async function getDocument(db){
    const snapshot = await db.collection('image_lense').onSnapshot(querySnapshot => {
        querySnapshot.docChanges().forEach(change => {
          if (change.type === 'added') {
            console.log('New city: ', change.doc.data());
          }
          if (change.type === 'modified') {
            console.log('Modified city: ', change.doc.data());
          }
          if (change.type === 'removed') {
            console.log('Removed city: ', change.doc.data());
          }
        }) });
          
};