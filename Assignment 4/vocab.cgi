#!/usr/bin/env python

# Import modules for CGI handling 
import cgi, cgitb 
import sys
import os
import random

cgitb.enable()	
    
questionList=[]
rightAns=[]
wrongAns=[]
class Question():
    def __init__(self, word, value, answers):
        self.word = word
        self.value = value
        self.answers = answers

def printQuestions():
    startQuestionPage()
    fetchDataFromFile('/home/unixtool/data/vocab.dat')
    printQuiz()    
    endQuestionPage()

def printQuiz():
    print '   <form action=vocab.cgi method=POST><br>'
    print '   <input type="hidden" id="check" name="check" value="1">'
    print '    <ol><br>'
    i = 0
    
    for ques in questionList:
        print '     <br>'
        print '     <li>'
        print '      <b>'+ques.word+'</b>: <br>'
        print '      <input type=hidden name=val'+str(i)+' value='+str(ques.value)+'>'
        print '      <input type=hidden name=ques'+str(i)+' value='+str(ques.word)+'>'
        j = 0
        for option in ques.answers:
            print '      <input type=radio name=q'+str(i)+' value='+str(j)+'>'+option
            print '      <br>'
            j = j + 1
        i = i + 1
    
    print '     </ol>'
    print '    <input type=SUBMIT value=Grade>'
    print '   </form>'
        
def fetchDataFromFile(vocabData):
    getNounsFromFile(vocabData)
    getVerbsFromFile(vocabData)
    getAdjectivesFromFile(vocabData)
    
def getVerbsFromFile(vocabData):
    
    verbs = random.sample(os.popen("grep '|v.|' "+ vocabData).readlines(),12)
    random.shuffle(verbs)
    i = 0
    while i < 12:
        questionLine = verbs[i]
        res = questionLine.split("|")
        questionWord = res[0]
        
        optionA = res[2]
        optionB = ((verbs[i+1]).split("|"))[2]
        optionC = ((verbs[i+2]).split("|"))[2]
        optionD = ((verbs[i+3]).split("|"))[2]
        optionList = [optionB, optionC, optionD]
        
        num = random.randint(0,3)
        optionList.insert(num, optionA)
        
        ques = Question(questionWord, num, optionList)
        questionList.append(ques)
        
        i = i + 4

def getAdjectivesFromFile(vocabData):
    
    adjectives = random.sample(os.popen("grep '|adj.|' "+ vocabData).readlines(),12)
    random.shuffle(adjectives)
    i = 0
    while i < 12:
        questionLine = adjectives[i]
        res = questionLine.split("|")
        questionWord = res[0]
        
        optionA = res[2]
        optionB = ((adjectives[i+1]).split("|"))[2]
        optionC = ((adjectives[i+2]).split("|"))[2]
        optionD = ((adjectives[i+3]).split("|"))[2]
        optionList = [optionB, optionC, optionD]
        
        num = random.randint(0,3)
        optionList.insert(num, optionA)
        
        ques = Question(questionWord, num, optionList)
        questionList.append(ques)
        
        i = i + 4
        
def getNounsFromFile(vocabData):
    
    nouns = random.sample(os.popen("grep '|n.|' "+ vocabData).readlines(),16)
    random.shuffle(nouns)
    i = 0
    while i < 16:
        questionLine = nouns[i]
        res = questionLine.split("|")
        questionWord = res[0]
        
        optionA = res[2]
        optionB = ((nouns[i+1]).split("|"))[2]
        optionC = ((nouns[i+2]).split("|"))[2]
        optionD = ((nouns[i+3]).split("|"))[2]
        optionList = [optionB, optionC, optionD]
        
        num = random.randint(0,3)
        optionList.insert(num, optionA)
        
        ques = Question(questionWord, num, optionList)
        questionList.append(ques)
        
        i = i + 4

def startQuestionPage():
    print 'Content-type:text/html\r\n\r\n'
    print '<html>'
    print ' <head>'
    print '  <title>sss665 : Vocabulary Quiz</title>'
    print ' </head>'
    print ' <body>'
    print '  <h2>Vocubulary Quiz</h2>'
    
def endQuestionPage():
    print ' </body>'
    print '</html>'
    
def startGradePage():
    print 'Content-type:text/html\r\n\r\n'
    print '<html>'
    print ' <head>'
    print '  <title>sss665 : Vocabulary Quiz Grades</title>'
    print ' </head>'
    print ' <body>'
    print '  <h2>Vocubulary Quiz Grades</h2>'

def endGradePage():
    print ' </body>'
    print '</html>'

def calculateGrade(form):
    right = 0 
    
    a0 = form.getvalue('q0')
    e0 = form.getvalue('val0')
    q0 = form.getvalue('ques0')
    
    a1 = form.getvalue('q1')
    e1 = form.getvalue('val1')
    q1 = form.getvalue('ques1')
    
    a2 = form.getvalue('q2')
    e2 = form.getvalue('val2')
    q2 = form.getvalue('ques2')
    
    a3 = form.getvalue('q3')
    e3 = form.getvalue('val3')
    q3 = form.getvalue('ques3')
    
    a4 = form.getvalue('q4')
    e4 = form.getvalue('val4')
    q4 = form.getvalue('ques4')
    
    a5 = form.getvalue('q5')
    e5 = form.getvalue('val5')
    q5 = form.getvalue('ques5')
    
    a6 = form.getvalue('q6')
    e6 = form.getvalue('val6')
    q6 = form.getvalue('ques6')
    
    a7 = form.getvalue('q7')
    e7 = form.getvalue('val7')
    q7 = form.getvalue('ques7')
    
    a8 = form.getvalue('q8')
    e8 = form.getvalue('val8')
    q8 = form.getvalue('ques8')
    
    a9 = form.getvalue('q9')
    e9 = form.getvalue('val9')
    q9 = form.getvalue('ques9')
    
    if (a0 == e0):
        rightAns.append(q0)
        right = right + 1
    else:
        wrongAns.append(q0)
        
    if (a1 == e1):
        rightAns.append(q1)
        right = right + 1
    else:
        wrongAns.append(q1)
        
    if (a2 == e2):
        rightAns.append(q2)
        right = right + 1
    else:
        wrongAns.append(q2)
    
    if (a3 == e3):
        rightAns.append(q3)
        right = right + 1
    else:
        wrongAns.append(q3)
        
    if (a4 == e4):
        rightAns.append(q4)
        right = right + 1
    else:
        wrongAns.append(q4)
        
    if (a5 == e5):
        rightAns.append(q5)
        right = right + 1
    else:
        wrongAns.append(q5)
        
    if (a6 == e6):
        rightAns.append(q6)
        right = right + 1
    else:
        wrongAns.append(q6)
        
    if (a7 == e7):
        rightAns.append(q7)
        right = right + 1
    else:
        wrongAns.append(q7)
        
    if (a8 == e8):
        rightAns.append(q8)
        right = right + 1
    else:
        wrongAns.append(q8)
        
    if (a9 == e9):
        rightAns.append(q9)
        right = right + 1
    else:
        wrongAns.append(q9)
        
    createResultTable(right)

def createResultTable(right):
    print '  <p>You got <b> '+ str(right) +' </b> out of <b> 10 </b> questions</p>'
    print '  <table border = 1>'
    print '   <br>'
    print '   <tr>'
    print '    <th> Correct'
    print '    <th> Incorrect'
    print '   </tr>'
    print '   <tr>'
    print '    <td valign = top>'
    print '     <font color = green>'
    for r in rightAns:
        print r + '<br>'
    print '     </font>'
    print '    </td>'
    print '    <td valign = top>'
    print '     <font color = red>'
    for w in wrongAns:
        print w + '<br>'
    print '     </font>'
    print '    </td>'
    print '   </tr>'
    print '  </table>'    
    
def printGrades(form):
    startGradePage()
    calculateGrade(form)
    endGradePage()
    
try:
    form = cgi.FieldStorage()
    if(form.getfirst("check") == "1"):
        printGrades(form)
    else:
        printQuestions()
    
except:
    cgi.print_exception()