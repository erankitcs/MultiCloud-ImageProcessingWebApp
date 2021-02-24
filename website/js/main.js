(
    function () {
        console.log('main js started.')
        $(document).ready(function () {
            console.log('main js started.')
            uploadController.init(configConstants,);
            imageController.init(configConstants);
        })
    }()
);