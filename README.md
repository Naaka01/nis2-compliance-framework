# NIS2 Cloud Compliance Framework

    > Terraform-based AWS infrastructure implementing NIS2 Directive
    > (EU 2022/2555) security controls for cloud environments.

    ## Architecture

    ## NIS2 Articles Covered
    | Article | Requirement | Status 
    | Art. 21 Risk & Access Management - Implemented 
    | Art. 23 Incident Notification - Implemented 

    ## Tech Stack
    - Terraform >= 1.7.0
    - AWS (eu-west-1)
    - Services: IAM, CloudTrail, S3, KMS, GuardDuty, Security Hub, Config, CloudWatch, SNS ...

    ## Modules
    | Module | Purpose | NIS2 Article |
    | iam | Access control, MFA enforcement, password policy | Art. 21 §2(j) 
    | logging | CloudTrail audit trail, encrypted S3, KMS | Art. 21 §2(h) 
    | detection | GuardDuty, Security Hub, 8 Config Rules | Art. 21 §2(b) 
    | alerting | CloudWatch alarms, SNS notifications | Art. 23 §1 


    ## Compliance Mapping
    See [compliance-mapping/nis2-controls.md](compliance-mapping/nis2-controls.md)

    ## Author
    Justesse Louboulat Milandou — Cloud Engineer
    GitHub: Naaka01 | LinkedIn: https://www.linkedin.com/in/justesse-louboulat-milandou-69370b400
