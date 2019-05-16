
# TODO:

#### Status abbrevations

| abbrevation | meaning                                      |
| ----------- |:-------------------------------------------- |
| COMP        | completed (per initial design)               |
| FUNC        | functional (working, but will have updates)  |
| IP          | in progress                                  |
| PL          | planned                                      |
| PROP        | proposed                                     |

## High level tasks
| task                                         | status |
|:-------------------------------------------- |:------ |
| Create documentation                         | IP     |
| Publish docker image and ruby gem            | IP     |
| Write unit tests                             | PL     |
| Write super classes for shared functionality | PL     |

## Functional ruby classes implementation

#### Storage class implementation status

| storage class | status      |
| ------------- |:----------- |
| file system   | FUNC        |
| consul        | PL          |

#### Watch Type class implementation status

| watch_type class | status      |
| ---------------- |:----------- |
| key/keyprefix    | FUNC        |
| checks           | IP          |
| services         | PL          |
| service          | PL          |
| nodes            | PL          |
| event            | PL          |

#### Destination class implementation status

| destination class | status      |
| ----------------- |:----------- |
| AMQP              | FUNC        |
| JQ                | FUNC        |
