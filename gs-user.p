/*if userid('coinsmas') <> 'mikec3' then do:
  message 'This is not enabled yet. If you need to add a user please contact Mike Cooper.'
  view-as alert-box information.
  return.
end.*/

def var v-cplogin     as char no-undo format 'x(50)'.
def var v-cprepid     as char no-undo format 'x(4)'.
def var v-newrepid    as char no-undo format 'x(4)'.
def var v-lastid1     as char no-undo format 'x(48)'.
def var v-lastid2     as char no-undo format 'x(48)'.
def var v-lastid3     as char no-undo format 'x(48)'.
def var v-lastid4     as char no-undo format 'x(48)'.
def var v-repids1     as char no-undo format 'x(48)'.
def var v-repids2     as char no-undo format 'x(48)'.
def var v-newlogin    as char no-undo format 'x(50)'.
def var v-newname     as char no-undo format 'x(50)'.
def var v-company     as char no-undo format 'x(12)'.
def var v-newemail    as char no-undo format 'x(50)'.
def var v-chngpw      as log  no-undo init yes.
def var v-updsecurity as log  no-undo init yes.
def var v-crlead      as log  no-undo.
def var v-ldsrcnm     as char no-undo format 'x(50)'.
def var v-ldsrcemail  as char no-undo format 'x(35)'.
def var v-runlist     as log  no-undo init yes.
def var v-crsmsn      as log  no-undo.
def var v-sasoo       as log  no-undo init yes.
def var v-ldsrcphone  as char no-undo format 'x(12)'.
def var v-lastval     as int  no-undo.
def var v-inttest     as int  no-undo.
def var v-choice      as log  no-undo.


def buffer bxrpt for xrpt.

/*
message 'Rep ID 1440 1445 1450 1452 1471 are available'
view-as alert-box error.
*/

  form v-lastid1     label 'Last Internal Rep ID'    colon 25 skip
       v-repids1     label 'Sees Reps'               colon 25 skip
       v-lastid2     label 'Last External Rep ID'    colon 25 skip
       v-repids2     label 'Sees Reps'               colon 25 skip
       v-lastid3     label 'Company Rep ID'          colon 25 skip
       v-lastid4     label 'Internal Manager Rep ID' colon 25 skip
       v-cplogin     label 'Copy From Login'         colon 25  skip
       v-newlogin    label 'New Login'               colon 25  skip
       v-newrepid    label 'New Rep ID'              colon 25
       v-company     label 'Company'                 colon 50  skip
       v-newname     label 'New Name'                colon 25  skip
       v-newemail    label 'New Email'               colon 25  skip
/*
       v-crlead      label 'Create Lead Source?'     colon 25
       v-ldsrcnm     label 'Lead Source Name'        colon 25  skip
       v-ldsrcphone  label 'Lead Source Phone'       colon 25 '(999-999-9999)'
       v-ldsrcemail  label 'Lead Source Email'       colon 25  skip
*/
       v-sasoo       label 'Use sasoo password?'     colon 25
       v-chngpw      label 'Change Password?'        colon 50
         help 'Only for external reps'
       v-updsecurity label 'Update Security?'
         help 'Only for external reps'               colon 25
       v-runlist     label 'Run List?'               colon 50  skip
/*
       v-crsmsn      label 'Create smsn?'            colon 50  skip
*/
  with frame f1 side-labels centered title 'Add User'.

on leave of v-newlogin do:
  assign v-newlogin
         v-cplogin.

  find first smsn where smsn.cono   = 1
                    and smsn.slsrep = v-newlogin no-lock no-error.
/*
if avail zsmsn then
disp '***AVAIL ZSMSN***' zsmsn.slsrep.
if avail smsn then
disp '***AVAIL SMSN***' smsn.slsrep.
/*return.*/
*/
  find first zsmsn where zsmsn.cono  = 1
                     and zsmsn.oper2 = v-newlogin no-lock no-error.
  if avail zsmsn then
      assign v-newrepid = zsmsn.slsrep
             v-newname  = zsmsn.name
             v-newemail = lc(replace(zsmsn.name,' ','.')) + '@fsgi.com'.

  if  v-newrepid = ''
  and avail smsn then
    assign v-newrepid = '9999'
           v-newname  = smsn.name
           v-newemail = lc(replace(smsn.name,' ','.')) + '@fsgi.com'.

  find xrpt where xrpt.cono     = 1
              and xrpt.oper2    = 'GSLogin'
              and xrpt.reportnm = 'GSLogin'
              and xrpt.c24      = v-cplogin no-lock no-error.

  if v-sasoo then
    find sasoo where sasoo.cono  = 1
                 and sasoo.oper2 = v-newlogin no-lock no-error.

  if  avail sasoo
  and v-newrepid <> '9900' then
    assign v-chngpw = false.

  if avail xrpt then
    assign v-newrepid = if v-newrepid = '' and xrpt.c8 begins '99' then xrpt.c8 else v-newrepid
           v-company  = xrpt.c12.

  if v-newrepid = ''
  and not avail smsn then
    assign v-sasoo    = false
           v-chngpw   = true
           v-newrepid = if not avail zsmsn then 'found but n/a' else 'n/a'
           v-newname  = if not avail zsmsn then 'found but n/a' else 'n/a'
           v-newemail = if not avail zsmsn then 'found but n/a' else 'n/a'
           v-company  = if not avail zsmsn then 'found but n/a' else 'n/a'.

  disp v-newrepid v-newname v-newemail v-company v-chngpw v-sasoo
  with frame f1.
end.


crblk:
repeat:
  for each xrpt where xrpt.cono           = 1
                  and xrpt.oper2          = 'GSLogin'
                  and xrpt.reportnm       = 'GSLogin'
                  and substr(xrpt.c8,1,2) = '14' no-lock
    by xrpt.c8:
    assign v-lastid1 = xrpt.c8 + ' (' + xrpt.c24 + ' - ' + xrpt.c24-2 + ')'
           v-repids1 = entry(2,entry(3,xrpt.c100,'^'),':').
  end.

  for each xrpt where xrpt.cono           = 1
                  and xrpt.oper2          = 'GSLogin'
                  and xrpt.reportnm       = 'GSLogin'
                  and substr(xrpt.c8,1,2) = '90' no-lock
    by xrpt.c8:
      assign v-lastid2 = xrpt.c8 + ' (' + xrpt.c24 + ' - ' + xrpt.c24-2 + ')'
           v-repids2 = entry(2,entry(3,xrpt.c100,'^'),':').
  end.

  for each xrpt where xrpt.cono     = 1
                  and xrpt.oper2    = 'GSLogin'
                  and xrpt.reportnm = 'GSLogin'
                  and xrpt.c8       = '9900' no-lock
    by xrpt.c8:
      assign v-lastid3 = xrpt.c8 + ' (' + xrpt.c24 + ' - ' + xrpt.c24-2 + ')'.
  end.

  for each xrpt where xrpt.cono     = 1
                  and xrpt.oper2    = 'GSLogin'
                  and xrpt.reportnm = 'GSLogin'
                  and xrpt.c8       = '9999' no-lock
    by xrpt.c8:
      assign v-lastid4 = xrpt.c8 + ' (' + xrpt.c24 + ' - ' + xrpt.c24-2 + ')'.
  end.

  disp v-lastid1
       v-repids1
       v-lastid2
       v-repids2
       v-lastid3
       v-lastid4
  with frame f1 side-labels centered.

  update v-cplogin
         v-newlogin
         v-newrepid
         v-company
         v-newname
         v-newemail
         v-sasoo
         v-chngpw
         v-updsecurity label 'Update Security?'
         v-runlist
  with frame f1 side-labels centered title 'Add User'.

  if  avail sasoo
  and v-newrepid = '9900' then do:
    message 'Internal FSG user (sasoo) exists for new external login ID'
    view-as alert-box error.
    next crblk.
	end.

  if lookup(v-newrepid,'9900,9999') = 0 then do:
    find xrpt where xrpt.cono     = 1
                and xrpt.oper2    = 'GSLogin'
                and xrpt.reportnm = 'GSLogin'
                and xrpt.c8       = v-newrepid no-lock no-error.

    if avail xrpt then do:
      message 'New Rep ID: ' + v-newrepid + ' already exists. Continue?'
        view-as alert-box question buttons yes-no update v-choice.
      if not v-choice then
        next crblk.
    end.
  end.

  find xrpt where xrpt.cono     = 1
              and xrpt.oper2    = 'GSLogin'
              and xrpt.reportnm = 'GSLogin'
              and xrpt.c24      = v-newlogin no-lock no-error.

  if avail xrpt then do:
    message 'New Login (xrpt) already exists'
    view-as alert-box error.
    next crblk.
  end.

  find xrpt where xrpt.cono     = 1
              and xrpt.oper2    = 'GSLogin'
              and xrpt.reportnm = 'GSLogin'
              and xrpt.c24      = v-cplogin no-lock no-error.

  if not avail xrpt then do:
    message 'Copy From Login (xrpt) not found'
    view-as alert-box error.
    next crblk.
  end.

  assign v-cprepid = xrpt.c8.

  /* Create user record */
  create bxrpt.
  buffer-copy xrpt to bxrpt.
  assign bxrpt.c8    = v-newrepid
         bxrpt.c24   = v-newlogin
         bxrpt.c24-2 = v-newname
         bxrpt.c12   = v-company
         bxrpt.c24-3 = if avail sasoo then sasoo.password else encode(v-newlogin)
         bxrpt.c20   = v-newemail
         bxrpt.c100  = replace(bxrpt.c100,v-cprepid,v-newrepid)
         bxrpt.l     = v-chngpw
         bxrpt.l-2   = true
         bxrpt.c8-2  = 'mikec3'
         bxrpt.dt    = ?.

  message 'User added'
  view-as alert-box information.

  if not avail sasoo then
    message 'sasoo not found. Password is user~'s log in ID'
    view-as alert-box information.
/*
  if v-crsmsn then do:
    create smsn.
    assign smsn.cono   = 1
           smsn.slsrep = v-newrepid
           smsn.name   = v-newname
           smsn.site   = 'do14'
           smsn.addr   = v-newlogin no-error.
    message 'smsn added'
    view-as alert-box information.
  end.

  if error-status:error then do:
    message 'Error creating smsn'
    view-as alert-box error.
    undo crblk, next.
  end.
*/
  if v-updsecurity then
    update bxrpt.c100 format 'x(300)'
    view-as editor size 76 by 5
    with frame f3 centered.

  if v-crlead then do:
    for each csast where csast.codeiden = 'pseglead'
    by int(csast.codeval):
      assign v-lastval = int(csast.codeval).
    end.
    create csast.
    assign csast.cono     = 1
           csast.codeiden = 'pseglead'
           csast.codeval  = string(v-lastval + 1)
           csast.descrip  = v-ldsrcnm
           csast.user3    = v-ldsrcemail
           csast.user4    = v-ldsrcphone.
    message 'Lead Source added'
    view-as alert-box information.
  end.
  if v-runlist then
    run gs-userrpt.p.
end.