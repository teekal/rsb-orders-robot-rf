*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get Orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Wait Until Keyword Succeeds    1min    1ms    Submit Form
        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        @{screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${pdf}    ${screenshot}
        Click Order another
    END
    Archive receipts
    [Teardown]    Close Browser


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    OK

Get Orders
    Download    https://robotsparebinindustries.com/orders.csv
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Fill the form
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:input[placeholder\="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

Submit form
    Click Button    Order
    Wait Until Page Contains Element    id:order-another

Click Order another
    Click Button    Order another robot

Store the receipt as a PDF file
    [Arguments]    ${Order number}
    ${html}=    Get Element Attribute    id:receipt    innerHTML
    Html To Pdf    ${html}    ${OUTPUT_DIR}/pdfs/${Order number}.pdf
    RETURN    ${OUTPUT_DIR}/pdfs/${Order number}.pdf

Take a screenshot of the robot
    [Arguments]    ${Order number}
    ${screen}=    Screenshot    id:receipt    ${OUTPUT_DIR}/pics/${Order number}.jpg
    @{screenAsList}=    Create List    ${screen}
    RETURN    @{screenAsList}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${pdf}    @{screenshot}
    Open Pdf    ${pdf}
    Add Files To Pdf    @{screenshot}    ${pdf}    ${True}
    Close All Pdfs

Archive receipts
    Archive Folder With Zip    ${OUTPUT_DIR}/pdfs    ${OUTPUT_DIR}/receipts.zip
