resource "google_firebase_project" "firebase" {
    provider = google-beta
    project  = "ultra-physics-269510"
}


/* resource "google_firebase_web_app" "imagelense_webapp" {
    provider = google-beta
    project = "ultra-physics-269510" 
    display_name = "Image Lense Web Apps."

    depends_on = [google_firebase_project.firebase]
}
 */

resource "google_app_engine_application" "imagelense" {
  project     = "ultra-physics-269510"    ##google_project.my_project.project_id
  location_id = "us-central"
  database_type = "CLOUD_FIRESTORE"
}

