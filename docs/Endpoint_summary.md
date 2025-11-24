openapi: "3.0.3"
info:
  title: "gandg_cms_api API"
  description: "gandg_cms_api API"
  version: "1.0.0"`
servers:
  - url: "https//72.61.19.130:8080"
paths:
  /api/v1/projects/{id}/requests:
    post:
      summary: "POST api/v1/projects/{id}/requests"
      operationId: "createRequest"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateRequestRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
  /api/v1/projects/{id}/requests/analytics:
    get:
      summary: "GET api/v1/projects/{id}/requests/analytics"
      operationId: "getAnalytics"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestAnalyticsResponse"
  /api/v1/requests:
    get:
      summary: "GET api/v1/requests"
      operationId: "listRequests"
      parameters:
        - name: "project_id"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
        - name: "requester_id"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
        - name: "status"
          in: "query"
          required: false
          schema:
            type: "string"
            enum:
              - "PENDING"
              - "APPROVED"
              - "REJECTED"
              - "CANCELLED"
        - name: "type"
          in: "query"
          required: false
          schema:
            type: "string"
            enum:
              - "FUNDS"
              - "MATERIALS"
              - "EQUIPMENT"
              - "OTHER"
              - "LEAVE"
        - name: "limit"
          in: "query"
          required: false
          schema:
            type: "integer"
            format: "int32"
            default: "50"
        - name: "offset"
          in: "query"
          required: false
          schema:
            type: "integer"
            format: "int32"
            default: "0"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
  /api/v1/requests/pending:
    get:
      summary: "GET api/v1/requests/pending"
      operationId: "getPendingApprovals"
      parameters:
        - name: "approver_id"
          in: "query"
          required: false
          schema:
            type: "string"
            default: "me"
        - name: "limit"
          in: "query"
          required: false
          schema:
            type: "integer"
            format: "int32"
            default: "50"
        - name: "offset"
          in: "query"
          required: false
          schema:
            type: "integer"
            format: "int32"
            default: "0"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
  /api/v1/requests/{id}:
    get:
      summary: "GET api/v1/requests/{id}"
      operationId: "getRequest"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
    patch:
      summary: "PATCH api/v1/requests/{id}"
      operationId: "updateRequest"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/UpdateRequestRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
    delete:
      summary: "DELETE api/v1/requests/{id}"
      operationId: "deleteRequest"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/requests/{id}/approve:
    post:
      summary: "POST api/v1/requests/{id}/approve"
      operationId: "approveRequest"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/ApproveRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
  /api/v1/requests/{id}/reject:
    post:
      summary: "POST api/v1/requests/{id}/reject"
      operationId: "rejectRequest"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/RejectRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/RequestResponse"
  /api/v1/approval-workflows/{id}:
    patch:
      summary: "PATCH api/v1/approval-workflows/{id}"
      operationId: "updateWorkflow"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateApprovalWorkflowRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ProjectApprovalWorkflowResponse"
  /api/v1/projects/{id}/approval-workflows:
    get:
      summary: "GET api/v1/projects/{id}/approval-workflows"
      operationId: "listWorkflows"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/ProjectApprovalWorkflowResponse"
    post:
      summary: "POST api/v1/projects/{id}/approval-workflows"
      operationId: "createWorkflow"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateApprovalWorkflowRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ProjectApprovalWorkflowResponse"
  /api/v1/sync/batch:
    post:
      summary: "POST api/v1/sync/batch"
      operationId: "batchUpload"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/SyncRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/sync/conflicts:
    get:
      summary: "GET api/v1/sync/conflicts"
      operationId: "getConflicts"
      parameters:
        - name: "userId"
          in: "query"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "status"
          in: "query"
          required: true
          schema:
            type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/ConflictResolution"
  /api/v1/sync/conflicts/{id}/resolve:
    post:
      summary: "POST api/v1/sync/conflicts/{id}/resolve"
      operationId: "resolveConflict"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              type: "string"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/sync/download:
    get:
      summary: "GET api/v1/sync/download"
      operationId: "download"
      parameters:
        - name: "projectId"
          in: "query"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "since"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "date-time"
        - name: "entities"
          in: "query"
          required: true
          schema:
            type: "array"
            items:
              type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/SyncResponse"
  /api/v1/issues/{id}:
    get:
      summary: "GET api/v1/issues/{id}"
      operationId: "getIssue"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueResponse"
    patch:
      summary: "PATCH api/v1/issues/{id}"
      operationId: "updateIssue"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/UpdateIssueRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueResponse"
    delete:
      summary: "DELETE api/v1/issues/{id}"
      operationId: "deleteIssue"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/issues/{id}/assign:
    patch:
      summary: "PATCH api/v1/issues/{id}/assign"
      operationId: "assignIssue"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/AssignIssueRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueResponse"
  /api/v1/issues/{id}/comments:
    get:
      summary: "GET api/v1/issues/{id}/comments"
      operationId: "getIssueComments"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/CommentResponse"
    post:
      summary: "POST api/v1/issues/{id}/comments"
      operationId: "createComment"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateCommentRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/CommentResponse"
  /api/v1/issues/{id}/history:
    get:
      summary: "GET api/v1/issues/{id}/history"
      operationId: "getIssueHistory"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueHistoryResponse"
  /api/v1/issues/{id}/media:
    get:
      summary: "GET api/v1/issues/{id}/media"
      operationId: "getIssueMedia"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/MediaResponse"
    post:
      summary: "POST api/v1/issues/{id}/media"
      operationId: "uploadIssueMedia"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "file"
          in: "query"
          required: true
          schema:
            type: "string"
            format: "binary"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/MediaResponse"
  /api/v1/issues/{id}/status:
    patch:
      summary: "PATCH api/v1/issues/{id}/status"
      operationId: "changeStatus"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/ChangeIssueStatusRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueResponse"
  /api/v1/issues/{issueId}/comments/{commentId}:
    patch:
      summary: "PATCH api/v1/issues/{issueId}/comments/{commentId}"
      operationId: "updateComment"
      parameters:
        - name: "issueId"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "commentId"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/UpdateCommentRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/CommentResponse"
    delete:
      summary: "DELETE api/v1/issues/{issueId}/comments/{commentId}"
      operationId: "deleteComment"
      parameters:
        - name: "issueId"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "commentId"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/projects/{id}/issues:
    get:
      summary: "GET api/v1/projects/{id}/issues"
      operationId: "getAllIssues"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "status"
          in: "query"
          required: false
          schema:
            type: "string"
            enum:
              - "OPEN"
              - "IN_PROGRESS"
              - "ON_HOLD"
              - "RESOLVED"
              - "CLOSED"
              - "REOPENED"
        - name: "assignee_id"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
        - name: "priority"
          in: "query"
          required: false
          schema:
            type: "string"
            enum:
              - "LOW"
              - "MEDIUM"
              - "HIGH"
              - "URGENT"
              - "CRITICAL"
        - name: "category"
          in: "query"
          required: false
          schema:
            type: "string"
        - name: "search"
          in: "query"
          required: false
          schema:
            type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueResponse"
    post:
      summary: "POST api/v1/projects/{id}/issues"
      operationId: "createIssue"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateIssueRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/IssueResponse"
  /api/v1/projects:
    get:
      summary: "GET api/v1/projects"
      operationId: "getAllProjects"
      parameters:
        - name: "status"
          in: "query"
          required: false
          schema:
            type: "string"
            enum:
              - "PLANNING"
              - "ACTIVE"
              - "ON_HOLD"
              - "COMPLETED"
              - "ARCHIVED"
        - name: "startDate"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "date"
        - name: "endDate"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "date"
        - name: "search"
          in: "query"
          required: false
          schema:
            type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ProjectResponse"
  /api/v1/projects/{id}:
    get:
      summary: "GET api/v1/projects/{id}"
      operationId: "getProject"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ProjectResponse"
  /api/v1/form-templates:
    get:
      summary: "GET api/v1/form-templates"
      operationId: "getFormTemplates"
      parameters:
        - name: "category"
          in: "query"
          required: false
          schema:
            type: "string"
        - name: "isActive"
          in: "query"
          required: false
          schema:
            type: "boolean"
        - name: "search"
          in: "query"
          required: false
          schema:
            type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/FormTemplateResponse"
  /api/v1/form-templates/{id}:
    get:
      summary: "GET api/v1/form-templates/{id}"
      operationId: "getFormTemplateById"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/FormTemplateResponse"
  /api/v1/form-templates/{id}/preview:
    get:
      summary: "GET api/v1/form-templates/{id}/preview"
      operationId: "previewFormTemplate"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/FormTemplateResponse"
  /api/v1/projects/{id}/reports:
    get:
      summary: "GET api/v1/projects/{id}/reports"
      operationId: "getProjectReports"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "dateFrom"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "date"
        - name: "dateTo"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "date"
        - name: "authorId"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/ReportResponse"
  /api/v1/reports:
    post:
      summary: "POST api/v1/reports"
      operationId: "createReport"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateReportRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ReportResponse"
  /api/v1/reports/search:
    get:
      summary: "GET api/v1/reports/search"
      operationId: "searchReports"
      parameters:
        - name: "q"
          in: "query"
          required: true
          schema:
            type: "string"
        - name: "projectId"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/ReportResponse"
  /api/v1/reports/{id}:
    get:
      summary: "GET api/v1/reports/{id}"
      operationId: "getReportById"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ReportResponse"
    put:
      summary: "PUT api/v1/reports/{id}"
      operationId: "updateReport"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/UpdateReportRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/ReportResponse"
    delete:
      summary: "DELETE api/v1/reports/{id}"
      operationId: "deleteReport"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/media:
    get:
      summary: "GET api/v1/media"
      operationId: "listMedia"
      parameters:
        - name: "project_id"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
        - name: "parent_type"
          in: "query"
          required: false
          schema:
            type: "string"
        - name: "parent_id"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "uuid"
        - name: "date_from"
          in: "query"
          required: false
          schema:
            type: "string"
            format: "date"
        - name: "limit"
          in: "query"
          required: false
          schema:
            type: "integer"
            format: "int32"
            default: "50"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/MediaResponse"
  /api/v1/media/upload:
    post:
      summary: "POST api/v1/media/upload"
      operationId: "uploadMedia"
      parameters:
        - name: "file"
          in: "query"
          required: true
          schema:
            type: "string"
            format: "binary"
        - name: "parent_type"
          in: "query"
          required: true
          schema:
            type: "string"
        - name: "parent_id"
          in: "query"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "metadata"
          in: "query"
          required: false
          schema:
            type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/MediaResponse"
  /api/v1/media/{id}:
    get:
      summary: "GET api/v1/media/{id}"
      operationId: "getMediaById"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/MediaResponse"
    delete:
      summary: "DELETE api/v1/media/{id}"
      operationId: "deleteMedia"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/media/{id}/download:
    get:
      summary: "GET api/v1/media/{id}/download"
      operationId: "downloadMedia"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/projects/{id}/media/gallery:
    get:
      summary: "GET api/v1/projects/{id}/media/gallery"
      operationId: "getProjectMediaGallery"
      parameters:
        - name: "id"
          in: "path"
          required: true
          schema:
            type: "string"
            format: "uuid"
        - name: "limit"
          in: "query"
          required: false
          schema:
            type: "integer"
            format: "int32"
            default: "50"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                type: "array"
                items:
                  $ref: "#/components/schemas/MediaResponse"
  /api/v1/auth/login:
    post:
      summary: "POST api/v1/auth/login"
      operationId: "login"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/LoginRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/AuthResponse"
  /api/v1/auth/logout:
    post:
      summary: "POST api/v1/auth/logout"
      operationId: "logout"
      parameters:
        - name: "Authorization"
          in: "header"
          required: true
          schema:
            type: "string"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/auth/mfa/disable:
    post:
      summary: "POST api/v1/auth/mfa/disable"
      operationId: "disableMfa"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/auth/mfa/enable:
    post:
      summary: "POST api/v1/auth/mfa/enable"
      operationId: "enableMfa"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/MfaVerifyRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/auth/mfa/setup:
    post:
      summary: "POST api/v1/auth/mfa/setup"
      operationId: "setupMfa"
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/MfaSetupResponse"
  /api/v1/auth/mfa/verify:
    post:
      summary: "POST api/v1/auth/mfa/verify"
      operationId: "verifyMfa"
      parameters:
        - name: "Authorization"
          in: "header"
          required: true
          schema:
            type: "string"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/MfaVerifyRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/AuthResponse"
  /api/v1/auth/password-reset/confirm:
    post:
      summary: "POST api/v1/auth/password-reset/confirm"
      operationId: "confirmPasswordReset"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/PasswordResetConfirmRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/auth/password-reset/request:
    post:
      summary: "POST api/v1/auth/password-reset/request"
      operationId: "requestPasswordReset"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/PasswordResetRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/Void"
  /api/v1/auth/refresh:
    post:
      summary: "POST api/v1/auth/refresh"
      operationId: "refreshToken"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/RefreshTokenRequest"
        required: true
      responses:
        "200":
          description: "OK"
          content:
            '*/*':
              schema:
                $ref: "#/components/schemas/AuthResponse"
components:
  schemas:
    BigDecimal:
      type: "object"
      properties: { }
    CreateRequestRequest:
      type: "object"
      properties:
        type:
          type: "string"
          nullable: true
          enum:
            - "FUNDS"
            - "MATERIALS"
            - "EQUIPMENT"
            - "OTHER"
            - "LEAVE"
        description:
          type: "string"
          nullable: true
        amount:
          nullable: true
          $ref: "#/components/schemas/BigDecimal"
        currency:
          type: "string"
          nullable: true
        priority:
          type: "string"
          nullable: true
          enum:
            - "LOW"
            - "MEDIUM"
            - "HIGH"
            - "URGENT"
            - "CRITICAL"
        metadata:
          type: "string"
          nullable: true
    UserResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        fullName:
          type: "string"
          nullable: true
        email:
          type: "string"
          nullable: true
        role:
          type: "string"
          nullable: true
          enum:
            - "ADMIN"
            - "PROJECT_MANAGER"
            - "SITE_ENGINEER"
            - "LABORER"
        status:
          type: "string"
          nullable: true
          enum:
            - "ACTIVE"
            - "INACTIVE"
            - "SUSPENDED"
        mfaEnabled:
          type: "boolean"
          nullable: true
        lastLoginAt:
          type: "string"
          format: "date-time"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    StepDTO:
      type: "object"
      properties:
        order:
          type: "integer"
          format: "int32"
          nullable: true
        role:
          type: "string"
          nullable: true
        status:
          type: "string"
          nullable: true
    ApprovalWorkflowDTO:
      type: "object"
      properties:
        steps:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/StepDTO"
        currentStep:
          type: "integer"
          format: "int32"
          nullable: true
    RequestResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        requestNumber:
          type: "string"
          nullable: true
        projectId:
          type: "string"
          format: "uuid"
          nullable: true
        requester:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        type:
          type: "string"
          nullable: true
          enum:
            - "FUNDS"
            - "MATERIALS"
            - "EQUIPMENT"
            - "OTHER"
            - "LEAVE"
        description:
          type: "string"
          nullable: true
        amount:
          nullable: true
          $ref: "#/components/schemas/BigDecimal"
        currency:
          type: "string"
          nullable: true
        priority:
          type: "string"
          nullable: true
          enum:
            - "LOW"
            - "MEDIUM"
            - "HIGH"
            - "URGENT"
            - "CRITICAL"
        status:
          type: "string"
          nullable: true
          enum:
            - "PENDING"
            - "APPROVED"
            - "REJECTED"
            - "CANCELLED"
        rejectionReason:
          type: "string"
          nullable: true
        approvalWorkflow:
          nullable: true
          $ref: "#/components/schemas/ApprovalWorkflowDTO"
        metadata:
          type: "string"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    RequestAnalyticsResponse:
      type: "object"
      properties:
        total:
          type: "integer"
          format: "int64"
          nullable: true
        statusCounts:
          type: "string"
          nullable: true
          enum:
            - "PENDING"
            - "APPROVED"
            - "REJECTED"
            - "CANCELLED"
        typeCounts:
          type: "string"
          nullable: true
          enum:
            - "FUNDS"
            - "MATERIALS"
            - "EQUIPMENT"
            - "OTHER"
            - "LEAVE"
    UpdateRequestRequest:
      type: "object"
      properties:
        description:
          type: "string"
          nullable: true
        amount:
          nullable: true
          $ref: "#/components/schemas/BigDecimal"
        currency:
          type: "string"
          nullable: true
        priority:
          type: "string"
          nullable: true
          enum:
            - "LOW"
            - "MEDIUM"
            - "HIGH"
            - "URGENT"
            - "CRITICAL"
        metadata:
          type: "string"
          nullable: true
    Void:
      type: "object"
      properties: { }
    ApproveRequest:
      type: "object"
      properties:
        comments:
          type: "string"
          nullable: true
        ipAddress:
          type: "string"
          nullable: true
        deviceInfo:
          type: "string"
          nullable: true
    RejectRequest:
      type: "object"
      properties:
        reason:
          type: "string"
          nullable: true
        comments:
          type: "string"
          nullable: true
    Step:
      type: "object"
      properties:
        stepOrder:
          type: "integer"
          format: "int32"
          nullable: true
        role:
          type: "string"
          nullable: true
        required:
          type: "boolean"
          nullable: true
    CreateApprovalWorkflowRequest:
      type: "object"
      properties:
        steps:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Step"
        active:
          type: "boolean"
          nullable: true
    ProjectApprovalWorkflowResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        projectId:
          type: "string"
          format: "uuid"
          nullable: true
        active:
          type: "boolean"
          nullable: true
        steps:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Step"
    Map:
      type: "object"
      properties: { }
    SyncRequest:
      type: "object"
      properties:
        created:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Map"
        updated:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Map"
        deleted:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Map"
    Permission:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        user:
          nullable: true
          $ref: "#/components/schemas/User"
        resource:
          type: "string"
          nullable: true
        action:
          type: "string"
          nullable: true
        description:
          type: "string"
          nullable: true
        granted:
          type: "boolean"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    UserNotificationPreferences:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        user:
          nullable: true
          $ref: "#/components/schemas/User"
        emailNotifications:
          type: "boolean"
          nullable: true
        pushNotifications:
          type: "boolean"
          nullable: true
        smsNotifications:
          type: "boolean"
          nullable: true
        projectUpdates:
          type: "boolean"
          nullable: true
        taskAssignments:
          type: "boolean"
          nullable: true
        deadlineReminders:
          type: "boolean"
          nullable: true
        systemAnnouncements:
          type: "boolean"
          nullable: true
        securityAlerts:
          type: "boolean"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    User:
      type: "object"
      properties:
        fullName:
          type: "string"
          nullable: true
        email:
          type: "string"
          nullable: true
        passwordHash:
          type: "string"
          nullable: true
        role:
          type: "string"
          nullable: true
          enum:
            - "ADMIN"
            - "PROJECT_MANAGER"
            - "SITE_ENGINEER"
            - "LABORER"
        status:
          type: "string"
          nullable: true
          enum:
            - "ACTIVE"
            - "INACTIVE"
            - "SUSPENDED"
        mfaEnabled:
          type: "boolean"
          nullable: true
        mfaSecret:
          type: "string"
          nullable: true
        lastLoginAt:
          type: "string"
          format: "date-time"
          nullable: true
        permissions:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Permission"
          uniqueItems: true
        notificationPreferences:
          nullable: true
          $ref: "#/components/schemas/UserNotificationPreferences"
        id:
          type: "string"
          format: "uuid"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
        deletedAt:
          type: "string"
          format: "date-time"
          nullable: true
        version:
          type: "integer"
          format: "int32"
          nullable: true
          default: "1"
    ConflictResolution:
      type: "object"
      properties:
        entityType:
          type: "string"
          nullable: true
        entityId:
          type: "string"
          format: "uuid"
          nullable: true
        user:
          nullable: true
          $ref: "#/components/schemas/User"
        serverVersion:
          type: "integer"
          format: "int32"
          nullable: true
        clientVersion:
          type: "integer"
          format: "int32"
          nullable: true
        serverData:
          type: "string"
          nullable: true
        clientData:
          type: "string"
          nullable: true
        resolutionStatus:
          type: "string"
          nullable: true
          enum:
            - "PENDING"
            - "RESOLVED_SERVER"
            - "RESOLVED_CLIENT"
            - "RESOLVED_MANUAL"
        resolvedBy:
          nullable: true
          $ref: "#/components/schemas/User"
        resolvedAt:
          type: "string"
          format: "date-time"
          nullable: true
        resolutionData:
          type: "string"
          nullable: true
        id:
          type: "string"
          format: "uuid"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
        deletedAt:
          type: "string"
          format: "date-time"
          nullable: true
        version:
          type: "integer"
          format: "int32"
          nullable: true
          default: "1"
    SyncResponse:
      type: "object"
      properties:
        created:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Map"
        updated:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/Map"
        deleted:
          type: "array"
          nullable: true
          items:
            type: "string"
    IssueResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        issueNumber:
          type: "string"
          nullable: true
        projectId:
          type: "string"
          format: "uuid"
          nullable: true
        author:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        assignee:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        title:
          type: "string"
          nullable: true
        description:
          type: "string"
          nullable: true
        status:
          type: "string"
          nullable: true
          enum:
            - "OPEN"
            - "IN_PROGRESS"
            - "ON_HOLD"
            - "RESOLVED"
            - "CLOSED"
            - "REOPENED"
        priority:
          type: "string"
          nullable: true
          enum:
            - "LOW"
            - "MEDIUM"
            - "HIGH"
            - "URGENT"
            - "CRITICAL"
        category:
          type: "string"
          nullable: true
        location:
          type: "string"
          nullable: true
        dueDate:
          type: "string"
          format: "date-time"
          nullable: true
        resolvedAt:
          type: "string"
          format: "date-time"
          nullable: true
        closedAt:
          type: "string"
          format: "date-time"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    UpdateIssueRequest:
      type: "object"
      properties:
        title:
          type: "string"
          nullable: true
        description:
          type: "string"
          nullable: true
        priority:
          type: "string"
          nullable: true
          enum:
            - "LOW"
            - "MEDIUM"
            - "HIGH"
            - "URGENT"
            - "CRITICAL"
        category:
          type: "string"
          nullable: true
        location:
          type: "string"
          nullable: true
        dueDate:
          type: "string"
          format: "date-time"
          nullable: true
    AssignIssueRequest:
      type: "object"
      properties:
        assigneeId:
          type: "string"
          format: "uuid"
          nullable: true
        comment:
          type: "string"
          nullable: true
    CommentResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        issueId:
          type: "string"
          format: "uuid"
          nullable: true
        author:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        content:
          type: "string"
          nullable: true
        type:
          type: "string"
          nullable: true
          enum:
            - "COMMENT"
            - "STATUS_CHANGE"
            - "ASSIGNMENT"
            - "ESCALATION"
        metadata:
          type: "string"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    CreateCommentRequest:
      type: "object"
      properties:
        content:
          type: "string"
          nullable: true
        type:
          type: "string"
          nullable: true
          enum:
            - "COMMENT"
            - "STATUS_CHANGE"
            - "ASSIGNMENT"
            - "ESCALATION"
    IssueHistoryResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        issueId:
          type: "string"
          format: "uuid"
          nullable: true
        user:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        action:
          type: "string"
          nullable: true
        fieldName:
          type: "string"
          nullable: true
        oldValue:
          type: "string"
          nullable: true
        newValue:
          type: "string"
          nullable: true
        metadata:
          type: "string"
          nullable: true
        timestamp:
          type: "string"
          format: "date-time"
          nullable: true
    MediaResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        fileUrl:
          type: "string"
          nullable: true
        fileType:
          type: "string"
          nullable: true
          enum:
            - "IMAGE"
            - "VIDEO"
            - "DOCUMENT"
            - "AUDIO"
            - "OTHER"
        fileSizeBytes:
          type: "integer"
          format: "int64"
          nullable: true
        mimeType:
          type: "string"
          nullable: true
        uploaderId:
          type: "string"
          format: "uuid"
          nullable: true
        uploaderName:
          type: "string"
          nullable: true
        metadata:
          type: "string"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
    ChangeIssueStatusRequest:
      type: "object"
      properties:
        newStatus:
          type: "string"
          nullable: true
          enum:
            - "OPEN"
            - "IN_PROGRESS"
            - "ON_HOLD"
            - "RESOLVED"
            - "CLOSED"
            - "REOPENED"
        comment:
          type: "string"
          nullable: true
    UpdateCommentRequest:
      type: "object"
      properties:
        content:
          type: "string"
          nullable: true
    CreateIssueRequest:
      type: "object"
      properties:
        title:
          type: "string"
          nullable: true
        description:
          type: "string"
          nullable: true
        status:
          type: "string"
          nullable: true
          enum:
            - "OPEN"
            - "IN_PROGRESS"
            - "ON_HOLD"
            - "RESOLVED"
            - "CLOSED"
            - "REOPENED"
        priority:
          type: "string"
          nullable: true
          enum:
            - "LOW"
            - "MEDIUM"
            - "HIGH"
            - "URGENT"
            - "CRITICAL"
        category:
          type: "string"
          nullable: true
        assigneeId:
          type: "string"
          format: "uuid"
          nullable: true
        dueDate:
          type: "string"
          format: "date"
          nullable: true
    ProjectResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        name:
          type: "string"
          nullable: true
        location:
          type: "string"
          nullable: true
        status:
          type: "string"
          nullable: true
          enum:
            - "PLANNING"
            - "ACTIVE"
            - "ON_HOLD"
            - "COMPLETED"
            - "ARCHIVED"
        budget:
          nullable: true
          $ref: "#/components/schemas/BigDecimal"
        startDate:
          type: "string"
          format: "date"
          nullable: true
        estimatedEndDate:
          type: "string"
          format: "date"
          nullable: true
        actualEndDate:
          type: "string"
          format: "date"
          nullable: true
        createdBy:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    FormFieldResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        label:
          type: "string"
          nullable: true
        fieldType:
          type: "string"
          nullable: true
          enum:
            - "TEXT"
            - "NUMBER"
            - "DATE"
            - "SELECT"
            - "MULTISELECT"
            - "MEDIA_UPLOAD"
            - "LOCATION"
        options:
          type: "array"
          nullable: true
          items:
            type: "string"
        isRequired:
          type: "boolean"
          nullable: true
        validationRules:
          type: "string"
          nullable: true
        displayOrder:
          type: "integer"
          format: "int32"
          nullable: true
    FormTemplateResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        name:
          type: "string"
          nullable: true
        description:
          type: "string"
          nullable: true
        category:
          type: "string"
          nullable: true
        isActive:
          type: "boolean"
          nullable: true
        createdBy:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        fields:
          type: "array"
          nullable: true
          items:
            $ref: "#/components/schemas/FormFieldResponse"
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    ReportSubmissionDataDTO:
      type: "object"
      properties:
        fields:
          type: "string"
          nullable: true
        formVersion:
          type: "integer"
          format: "int32"
          nullable: true
    LocationDataDTO:
      type: "object"
      properties:
        latitude:
          type: "number"
          format: "double"
          nullable: true
        longitude:
          type: "number"
          format: "double"
          nullable: true
        accuracy:
          type: "number"
          format: "double"
          nullable: true
        address:
          type: "string"
          nullable: true
        capturedAt:
          type: "string"
          format: "date-time"
          nullable: true
    ReportResponse:
      type: "object"
      properties:
        id:
          type: "string"
          format: "uuid"
          nullable: true
        reportNumber:
          type: "string"
          nullable: true
        projectId:
          type: "string"
          format: "uuid"
          nullable: true
        projectName:
          type: "string"
          nullable: true
        authorId:
          type: "string"
          format: "uuid"
          nullable: true
        authorName:
          type: "string"
          nullable: true
        formTemplateId:
          type: "string"
          format: "uuid"
          nullable: true
        formTemplateName:
          type: "string"
          nullable: true
        reportDate:
          type: "string"
          format: "date"
          nullable: true
        submissionData:
          nullable: true
          $ref: "#/components/schemas/ReportSubmissionDataDTO"
        location:
          nullable: true
          $ref: "#/components/schemas/LocationDataDTO"
        status:
          type: "string"
          nullable: true
          enum:
            - "DRAFT"
            - "SUBMITTED"
            - "REVIEWED"
        submittedAt:
          type: "string"
          format: "date-time"
          nullable: true
        createdAt:
          type: "string"
          format: "date-time"
          nullable: true
        updatedAt:
          type: "string"
          format: "date-time"
          nullable: true
    CreateReportRequest:
      type: "object"
      properties:
        projectId:
          type: "string"
          format: "uuid"
          nullable: true
        formTemplateId:
          type: "string"
          format: "uuid"
          nullable: true
        reportDate:
          type: "string"
          format: "date"
          nullable: true
        submissionData:
          nullable: true
          $ref: "#/components/schemas/ReportSubmissionDataDTO"
        location:
          nullable: true
          $ref: "#/components/schemas/LocationDataDTO"
    UpdateReportRequest:
      type: "object"
      properties:
        reportDate:
          type: "string"
          format: "date"
          nullable: true
        submissionData:
          nullable: true
          $ref: "#/components/schemas/ReportSubmissionDataDTO"
        location:
          nullable: true
          $ref: "#/components/schemas/LocationDataDTO"
        status:
          type: "string"
          nullable: true
          enum:
            - "DRAFT"
            - "SUBMITTED"
            - "REVIEWED"
    LoginRequest:
      type: "object"
      properties:
        email:
          type: "string"
          nullable: true
        password:
          type: "string"
          nullable: true
        mfaCode:
          type: "string"
          nullable: true
    AuthResponse:
      type: "object"
      properties:
        accessToken:
          type: "string"
          nullable: true
        refreshToken:
          type: "string"
          nullable: true
        tokenType:
          type: "string"
          nullable: true
        expiresIn:
          type: "integer"
          format: "int64"
          nullable: true
        user:
          nullable: true
          $ref: "#/components/schemas/UserResponse"
        mfaRequired:
          type: "boolean"
          nullable: true
        mfaTempToken:
          type: "string"
          nullable: true
    MfaVerifyRequest:
      type: "object"
      properties:
        code:
          type: "string"
          nullable: true
    MfaSetupResponse:
      type: "object"
      properties:
        secret:
          type: "string"
          nullable: true
        qrCodeUrl:
          type: "string"
          nullable: true
        issuer:
          type: "string"
          nullable: true
        accountName:
          type: "string"
          nullable: true
    PasswordResetConfirmRequest:
      type: "object"
      properties:
        token:
          type: "string"
          nullable: true
        newPassword:
          type: "string"
          nullable: true
        confirmPassword:
          type: "string"
          nullable: true
    PasswordResetRequest:
      type: "object"
      properties:
        email:
          type: "string"
          nullable: true
    RefreshTokenRequest:
      type: "object"
      properties:
        refreshToken:
          type: "string"
          nullable: true
