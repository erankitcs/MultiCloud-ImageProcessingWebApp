resource "google_firebase_project" "firebase" {
    provider = google-beta
    project  = var.gcp_project_name
}


/* resource "google_firebase_web_app" "imagelense_webapp" {
    provider = google-beta
    project = var.gcp_project_name
    display_name = "Image Lense Web Apps."

    depends_on = [google_firebase_project.firebase]
}
 */

resource "google_app_engine_application" "imagelense" {
  project     = var.gcp_project_name    ##google_project.my_project.project_id
  location_id = "us-central"
  database_type = "CLOUD_FIRESTORE"
}

