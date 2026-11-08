from pathlib import Path
import json,sys
p=Path(__file__).resolve().parents[1]
status=json.loads((p/'STATUS.json').read_text(encoding='utf-8'))
t=(p/'submission/my_submission.template.txt').read_text(encoding='utf-8')
problems=[]
for key in ['team-name','repo-url','github-username','contact-email']:
    value=next((x.split(':',1)[1].strip() for x in t.splitlines() if x.startswith(key+':')),'')
    if not value or '待填写' in value:problems.append(key+' is missing')
if not status['contest_semantics_confirmed']:problems.append('Result-width interpretation still needs official review')
if problems:print('LOCAL TECHNICAL PACKAGE READY; external submission pending:\n'+'\n'.join(problems));sys.exit(2)
print('Submission fields filled. Review public contents and follow official encrypted submission workflow.')
