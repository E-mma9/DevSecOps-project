# In de AWS Learner Lab mogen studenten geen IAM rollen aanmaken.
# De Learner Lab heeft een vooraf aangemaakte rol "LabRole" met de benodigde rechten.
# We zoeken die op via een data source in plaats van zelf rollen aan te maken.

data "aws_iam_role" "lab_role" {
  name = "LabRole" # vooraf aangemaakte rol in de AWS Learner Lab omgeving
}
