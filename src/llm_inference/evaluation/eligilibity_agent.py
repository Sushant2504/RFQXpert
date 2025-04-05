import logging
from llm_inference.utils.gemini import gemini_client
import json
import re
logger = logging.getLogger(__name__)

ELIGIBILITY_PROMPT = """Analyze this RFP and company profile to determine eligibility:
RFP: {rfp_text}

Company Profile: {company_profile}

Tasks:
1. List all MANDATORY requirements from RFP
2. Check which requirements are met by the company
4. If there is any ambiguity, apply critical thinking to judge whether company can meet the requirement.
3. Provide clear yes/no eligibility conclusion

Return JSON format:
{{
  "meets_criteria": boolean,
  "met_requirements": [strings],
  "unmet_requirements": [strings],
  "reasons": [strings],
  "recommendations": [strings]
}}"""

async def evaluate_eligibility(rfp_text: str, company_profile: dict) -> dict:
    try:
        prompt = ELIGIBILITY_PROMPT.format(
            rfp_text=rfp_text,
            company_profile=company_profile
        )
        
        response = await gemini_client.generate_content(prompt)
        return parse_gemini_response(response)
        
    except Exception as e:
        logger.error(f"Gemini eligibility error: {str(e)}")
        raise

def parse_gemini_response(response) -> dict:
    """
    Parse the JSON response from Gemini API.
    
    Args:
        response: Response object from Gemini API
        
    Returns:
        dict: Parsed eligibility assessment data
    """
    try:
        # Extract text content from the response
        text_content = response.text
        
        # Try to find JSON in the response using regex
        json_pattern = r'({[\s\S]*})'
        json_matches = re.search(json_pattern, text_content)
        
        if json_matches:
            json_str = json_matches.group(1)
            # Parse the JSON string
            eligibility_data = json.loads(json_str)
            
            # Validate the structure
            validate_eligibility_data(eligibility_data)
            
            return eligibility_data
        else:
            # No JSON found, fallback to a basic structure
            logger.warning("No valid JSON found in Gemini response")
            return create_fallback_response("No valid JSON found in model response")
            
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON from Gemini response: {str(e)}")
        return create_fallback_response(f"JSON parsing error: {str(e)}")
        
    except ValueError as e:
        logger.error(f"Invalid eligibility data structure: {str(e)}")
        return create_fallback_response(f"Data validation error: {str(e)}")
        
    except Exception as e:
        logger.error(f"Unexpected error parsing Gemini response: {str(e)}")
        return create_fallback_response(f"Unexpected error: {str(e)}")

def validate_eligibility_data(data: dict) -> None:
    """
    Validate that the eligibility data contains all required fields.
    
    Args:
        data: Parsed JSON data
        
    Raises:
        ValueError: If data is missing required fields
    """
    required_keys = ["meets_criteria", "met_requirements", "unmet_requirements", 
                     "reasons", "recommendations"]
    
    for key in required_keys:
        if key not in data:
            raise ValueError(f"Missing required field: {key}")
    
    # Validate data types
    if not isinstance(data["meets_criteria"], bool):
        raise ValueError("'meets_criteria' must be a boolean")
        
    for list_field in ["met_requirements", "unmet_requirements", "reasons", "recommendations"]:
        if not isinstance(data[list_field], list):
            raise ValueError(f"'{list_field}' must be a list")
            
        # Validate that all items in lists are strings
        if not all(isinstance(item, str) for item in data[list_field]):
            raise ValueError(f"All items in '{list_field}' must be strings")

def create_fallback_response(error_message: str) -> dict:
    """
    Create a fallback response when parsing fails.
    
    Args:
        error_message: Description of the error
        
    Returns:
        dict: Structured fallback response
    """
    return {
        "meets_criteria": False,
        "met_requirements": [],
        "unmet_requirements": ["Unable to determine requirements"],
        "reasons": [f"Response analysis failed: {error_message}"],
        "recommendations": [
            "Try again with more structured RFP information",
            "Review RFP manually to verify requirements",
            "Contact support if the issue persists"
        ]
    }