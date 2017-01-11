***INCLUDE LBTCHF15 .
*
*&---------------------------------------------------------------------*
*&      Form  move_attributes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TSP01ATTR  text
*      <--P_SPOOLATTR  text
*----------------------------------------------------------------------*
FORM move_attributes  USING    tsp01attr STRUCTURE tsp01
                      CHANGING spoolattr STRUCTURE bapixmspoolid.

  MOVE tsp01attr-rqident TO spoolattr-spoolid.
  MOVE tsp01attr-rqclient TO spoolattr-client.
  MOVE tsp01attr-rq0name TO spoolattr-name.
  MOVE tsp01attr-rq1name TO spoolattr-suffix1.
  MOVE tsp01attr-rq2name TO spoolattr-suffix2.
  MOVE tsp01attr-rqowner TO spoolattr-owner.
  MOVE tsp01attr-rqfinal TO spoolattr-final.
  MOVE tsp01attr-rqcretime TO spoolattr-crtime.
  MOVE tsp01attr-rqdeltime TO spoolattr-dltime.
  MOVE tsp01attr-rqapprule TO spoolattr-spopages.
  MOVE tsp01attr-rq1dispo TO spoolattr-printtime.
  MOVE tsp01attr-rq2dispo TO spoolattr-delafterprint.
  MOVE tsp01attr-rqdest TO spoolattr-device.
  MOVE tsp01attr-rqcopies TO spoolattr-copies.
  MOVE tsp01attr-rqprio TO spoolattr-priority.
  MOVE tsp01attr-rqpaper TO spoolattr-spoformat.
  MOVE tsp01attr-rqpjreq TO spoolattr-pjtotal.
  MOVE tsp01attr-rqpjdone TO spoolattr-pjdone.
  MOVE tsp01attr-rqpjserr TO spoolattr-pjproblem.
  MOVE tsp01attr-rqpjherr TO spoolattr-pjerror.
  MOVE tsp01attr-rqwriter TO spoolattr-writer.
  MOVE tsp01attr-rqerror TO spoolattr-sperror.
  MOVE tsp01attr-rqo1name TO spoolattr-temsename.
  MOVE tsp01attr-rqo1part TO spoolattr-temsepart.
  MOVE tsp01attr-rqo1clie TO spoolattr-temseclient.
  MOVE tsp01attr-rqtitle TO spoolattr-title.
  MOVE tsp01attr-rqsaptitle TO spoolattr-sapcover.
  MOVE tsp01attr-rqunxtitle TO spoolattr-oscover.
  MOVE tsp01attr-rqreceiver TO spoolattr-receiver.
  MOVE tsp01attr-rqdivision TO spoolattr-division.
  MOVE tsp01attr-rqauth TO spoolattr-authority.
  MOVE tsp01attr-rqmodtime TO spoolattr-modtime.
  MOVE tsp01attr-rqdoctype TO spoolattr-doctyp.
  MOVE tsp01attr-rqposname TO spoolattr-osname.

ENDFORM.                    " move_attributes
