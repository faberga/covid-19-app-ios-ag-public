//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class SandboxDistributeClient: HTTPClient {
    private let queue = DispatchQueue(label: "sandbox-distribution-client")
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).publisher
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    private func _perform(_ request: HTTPRequest) -> Result<HTTPResponse, HTTPRequestError> {
        if request.path == "/distribution/symptomatic-questionnaire" {
            return Result.success(.ok(with: .json(questionnaire)))
        }
        if request.path == "/distribution/self-isolation" {
            return Result.success(.ok(with: .json(isolationConfig)))
        }
        if request.path == "/distribution/risky-post-districts-v2" {
            return .success(.ok(with: .json(riskyPostcodes)))
        }
        
        return Result.failure(.rejectedRequest(underlyingError: SimpleError("")))
    }
}

private let isolationConfig = """
{
  "durationDays": {
    "indexCaseSinceSelfDiagnosisOnset": 1,
    "indexCaseSinceSelfDiagnosisUnknownOnset": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset),
    "contactCase": 3,
    "maxIsolation": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset)
  }
}

"""

private let questionnaire = """
{
  "symptoms": [
    {
      "title": {
        "en-GB": "\(Sandbox.Text.SymptomsList.cardHeading.rawValue)"
      },
      "description": {
        "en-GB": "\(Sandbox.Text.SymptomsList.cardContent.rawValue)"
      },
      "riskWeight": 1
    }
  ],
  "riskThreshold": 0.5,
  "symptomsOnsetWindowDays": 5
}
"""

private func policyData(alertLevel: Int) -> String {
    """
    {
        "localAuthorityRiskTitle": {
            "en": "[local authority] ([postcode]) is in Local Alert Level \(alertLevel)"
        },
        "heading": {
            "en": "Coronavirus cases are very high in your area"
        },
        "content": {
            "en": "The restrictions placed on areas with a very high level of infections can vary and are based on discussions between central and local government. You should check the specific rules in your area."
        },
        "footer": {
            "en": "Find out what rules apply in your area to help reduce the spread of coronavirus."
        },
        "policies": [
            {
                "policyIcon": "default-icon",
                "policyHeading": {
                    "en": "Default"
                },
                "policyContent": {
                    "en": "Venues must close…"
                }
            },
            {
                "policyIcon": "meeting-people",
                "policyHeading": {
                    "en": "Meeting people"
                },
                "policyContent": {
                    "en": "No household mixing indoors or outdoors in venues or private gardens. Rule of six applies in outdoor public spaces like parks."
                }
            },
            {
                "policyIcon": "bars-and-pubs",
                "policyHeading": {
                    "en": "Bars and pubs"
                },
                "policyContent": {
                    "en": "Venues not serving meals will be closed."
                }
            },
            {
                "policyIcon": "worship",
                "policyHeading": {
                    "en": "Worship"
                },
                "policyContent": {
                    "en": "These remain open, subject to indoor or outdoor venue restrictions."
                }
            },
            {
                "policyIcon": "overnight-stays",
                "policyHeading": {
                    "en": "Overnight Stays"
                },
                "policyContent": {
                    "en": "If you have to travel, avoid staying overnight."
                }
            },
            {
                "policyIcon": "education",
                "policyHeading": {
                    "en": "Education"
                },
                "policyContent": {
                    "en": "Schools, colleges and universities remain open, with restrictions."
                }
            },
            {
                "policyIcon": "travelling",
                "policyHeading": {
                    "en": "Travelling"
                },
                "policyContent": {
                    "en": "Avoid travelling around or leaving the area, other than for work, education, youth services or because of caring responsibilities."
                }
            },
            {
                "policyIcon": "exercise",
                "policyHeading": {
                    "en": "Exercise"
                },
                "policyContent": {
                    "en": "Classes and organised adult sport are allowed outdoors and only allowed indoors if no household mixing. Sports for the youth and disabled is allowed indoors and outdoors."
                }
            },
            {
                "policyIcon": "weddings-and-funerals",
                "policyHeading": {
                    "en": "Weddings and Funerals"
                },
                "policyContent": {
                    "en": "Up to 15 guests for weddings, 30 for funerals and 15 for wakes. Wedding receptions not permitted."
                }
            }
        ]
    }
    """
}

private let riskyPostcodes = """
{
    "postDistricts" : {
        "SW12": "green",
        "SW13": "amber",
        "SW14": "yellow",
        "SW15": "red",
        "SW16": "neutral",
    },
    "localAuthorities": {
        "E09000022": "green",
        "E09000023": "amber",
        "E09000024": "yellow",
        "E09000025": "red",
        "E09000026": "neutral",
    },
    "riskLevels" : {
        "red": {
            "colorScheme": "red",
            "name": { "en": "[postcode] is in Local Alert Level 3" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 3))
        },
        "amber": {
            "colorScheme": "amber",
            "name": { "en": "[postcode] is in Local Alert Level 3" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 3))
        },
        "yellow": {
            "colorScheme": "yellow",
            "name": { "en": "[postcode] is in Local Alert Level 2" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 2))
        },
        "green": {
            "colorScheme": "green",
            "name": { "en": "[postcode] is in Local Alert Level 1" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 1))
        },
        "neutral": {
            "colorScheme": "neutral",
            "name": { "en": "[postcode] is in Local Alert Level 1" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 1))
        }
    }
}
"""
