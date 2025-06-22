import os

# Set your API Key
os.environ["MISTRAL_API_KEY"] = "MISTRAL_API_KEY"

from langchain_mistralai import ChatMistralAI
from langchain_community.document_loaders import TextLoader
from langchain_chroma import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_text_splitters import RecursiveCharacterTextSplitter
from mistralai import Mistral
from langchain_core.documents import Document 
from langchain import hub
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

# Initialize Mistral model for summarization
llm = ChatMistralAI(model="mistral-large-latest")

# Helper function to summarize input text
def summarize_text(input_text: str) -> str:
    # Load the input text and process it
    docs = [Document(page_content=input_text)] 
    
    # Initialize the embeddings function
    embedding_function = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

    # Split the input text into chunks for processing
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
    splits = text_splitter.split_documents(docs)

    # Create a Chroma vector store for document embeddings
    vectorstore = Chroma.from_documents(documents=splits, embedding=embedding_function)

    # Setup the retriever to fetch relevant chunks
    retriever = vectorstore.as_retriever()
    prompt = hub.pull("rlm/rag-prompt")

    # Function to format the docs into text
    def format_docs(docs):
        return "\n\n".join(doc.page_content for doc in docs)

    # Chain setup to generate the summary
    rag_chain = (
        {"context": retriever | format_docs, "question": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )

    # Get the summary by invoking the chain
    summary = rag_chain.invoke("Summarize")
    return summary

from fastapi import FastAPI
from pydantic import BaseModel

# Define the request data model
class TextRequest(BaseModel):
    text: str

@app.get("/")
def home():
    return {"message": "API is running!"}

    
@app.post("/summarize")
async def summarize(request: TextRequest):
    input_text = request.text
    summary = summarize_text(input_text)
    return summary

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)